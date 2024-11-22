class ShopifyProductService
  def initialize(shop_domain, access_token)
    @shop_domain = shop_domain
    @access_token = access_token

    @session = ShopifyAPI::Auth::Session.new(
      shop: shop_domain,
      access_token: access_token
    )
    @client = ShopifyAPI::Clients::Graphql::Admin.new(
      session: @session
    )
  end

  def create_product_with_variants_and_inventory(product_params, variant_params, media_params, product)
    product_id_info = create_product(product_params, variant_params, product)

    return unless product_id_info

    add_product_media(product_id_info[:product_id], media_params)

    product_id_info[:product_id]
  end

  def fetch_location_id
    query = <<~QUERY
      {
        locations(first: 1) {
          edges {
            node {
              id
              name
            }
          }
        }
      }
    QUERY

    response = @client.query(query: query)

    if response.body["data"]["locations"]["edges"].any?
      response.body["data"]["locations"]["edges"][0]["node"]["id"]
    else
      puts "No locations found"
      nil
    end
  end

  # Create the product
  def create_product(product_params, variant_params, product)
    query = <<~GRAPHQL
      mutation CreateProductWithOptions($input: ProductInput!) {
        productCreate(input: $input) {
          product {
            id
            title
            bodyHtml
            vendor
            productType
            options {
              name
              values
              id
              position
            }
            variants(first: 5) {
              nodes {
                id
                title
                selectedOptions {
                  name
                  value
                }
                price
                sku
                weight
                weightUnit
                inventoryItem {
                  id # Needed to adjust inventory
                }
              }
            }
          }
          userErrors {
            message
            field
          }
        }
      }
    GRAPHQL

    options = %w[Model Color Size]
    variants = variant_params.map do |variant|
      {
        title: variant[:title],
        sku: variant[:stock_id].to_s,
        price: variant[:final_price],
        weight: variant[:weight],
        weightUnit: variant[:weightUnit],
        requiresShipping: true,
        options: [variant[:model], variant[:color], variant[:size]]
      }
    end

    variables = {
      "input": {
        "title": product_params[:title],
        "bodyHtml": product_params[:bodyHtml],
        "vendor": product_params[:vendor],
        "productType": product_params[:productType],
        "options": options,
        "variants": variants
      }
    }

    response = @client.query(query: query, variables: variables)
    user_errors = response.body.dig("data", "productCreate", "userErrors")

    if user_errors && user_errors.any?
      user_errors.each do |error|
        puts "Error creating product: #{error['message']} (Field: #{error['field']})"
      end
      return nil
    end


    publish_product_to_store(response.body.dig('data', 'productCreate', 'product', 'id'))
    product_data = response.body.dig("data", "productCreate", "product")
    variants_data = product_data&.dig("variants", "nodes")

    unless product_data && variants_data
      puts "Error: Product or variant data is missing in the response."
      return nil
    end

    variants_data.each_with_index do |variant, index|
      save_variant_to_db(
        product_id: product.id,
        shopify_product_id: product_data['id']&.gsub(/\D/, ''),
        shopify_variant_id: variant['id']&.gsub(/\D/, ''),
        title: variant['title'],
        sku: variant['sku'],
        price: variant['price'],
        weight: variant['weight'],
        weight_unit: variant['weightUnit']
      )

      if variant_params[index][:inventoryQuantity]
        adjust_inventory_quantity(variant['inventoryItem']['id'], variant_params[index][:inventoryQuantity], variant['id'])
        enable_inventory_tracking(variant['id'])
      end
    end

    { product_id: product_data['id'] }
  rescue => e
    puts "An unexpected error occurred while creating the product: #{e.message}"
    nil
  end

  def fetch_inventory_level_id(inventory_item_id)
    query = <<~GRAPHQL
      query($inventoryItemId: ID!) {
        inventoryItem(id: $inventoryItemId) {
          inventoryLevels(first: 1) {
            edges {
              node {
                id
                available
                location {
                  id
                }
              }
            }
          }
        }
      }
    GRAPHQL

    variables = { "inventoryItemId": inventory_item_id }
    response = @client.query(query: query, variables: variables)

    inventory_level_id = response.body.dig("data", "inventoryItem", "inventoryLevels", "edges", 0, "node", "id")
    inventory_level_id
  rescue => e
    puts "An error occurred while fetching inventory level ID: #{e.message}"
    nil
  end

  def enable_inventory_tracking(shopify_variant_id)
    query = <<~GRAPHQL
      mutation UpdateVariant($input: ProductVariantInput!) {
        productVariantUpdate(input: $input) {
          productVariant {
            id
            inventoryManagement
          }
          userErrors {
            field
            message
          }
        }
      }
    GRAPHQL

    variables = {
      "input": {
        "id": shopify_variant_id,
        "inventoryManagement": "SHOPIFY"
      }
    }

    response = @client.query(query: query, variables: variables)
    user_errors = response.body.dig("data", "productVariantUpdate", "userErrors")

    if user_errors && user_errors.any?
      user_errors.each do |error|
        puts "Error enabling inventory tracking: #{error['message']} (Field: #{error['field']})"
      end
    else
      puts "Inventory tracking enabled for variant #{shopify_variant_id}."
    end
  end

  def adjust_inventory_quantity(inventory_item_id, quantity, shopify_variant_id)
    inventory_level_id = fetch_inventory_level_id(inventory_item_id)
    return unless inventory_level_id

    query = <<~GRAPHQL
      mutation AdjustInventory($inventoryLevelId: ID!, $availableDelta: Int!) {
        inventoryAdjustQuantity(input: {inventoryLevelId: $inventoryLevelId, availableDelta: $availableDelta}) {
          inventoryLevel {
            id
            available
          }
          userErrors {
            field
            message
          }
        }
      }
    GRAPHQL

    variables = {
      "inventoryLevelId": inventory_level_id,
      "availableDelta": quantity
    }

    response = @client.query(query: query, variables: variables)
    user_errors = response.body.dig("data", "inventoryAdjustQuantity", "userErrors")

    if user_errors && user_errors.any?
      user_errors.each do |error|
        puts "Error adjusting inventory: #{error['message']} (Field: #{error['field']})"
      end
    else
      available_quantity = response.body.dig("data", "inventoryAdjustQuantity", "inventoryLevel", "available")
      variant_record = Variant.find_by(shopify_variant_id: shopify_variant_id&.gsub(/\D/, ''))
      if variant_record
        variant_record.update(inventory_quantity: available_quantity, inventory_item_id: inventory_item_id&.gsub(/\D/, ''))
        puts "Inventory updated successfully for variant #{shopify_variant_id} to #{available_quantity}."
      else
        puts "Error: Variant with Shopify ID #{shopify_variant_id} not found in the database."
      end
    end
  end

  def add_product_media(product_id, media_params)
    query = <<~QUERY
      mutation productCreateMedia($media: [CreateMediaInput!]!, $productId: ID!) {
        productCreateMedia(media: $media, productId: $productId) {
          media {
            alt
            mediaContentType
            status
          }
          mediaUserErrors {
            field
            message
          }
        }
      }
    QUERY

    variables = {
      "media": media_params,
      "productId": product_id
    }

    response = @client.query(query: query, variables: variables)

    if response.body["data"]["productCreateMedia"]["mediaUserErrors"].empty?
      puts "Media added successfully"
    else
      puts "Error adding media: #{response.body["data"]["productCreateMedia"]["mediaUserErrors"]}"
    end
  end

  def update_product_price(shopify_product_id, new_price)
    query = <<~QUERY
      mutation productVariantUpdate($input: ProductVariantInput!) {
        productVariantUpdate(input: $input) {
          productVariant {
            id
            price
          }
          userErrors {
            field
            message
          }
        }
      }
    QUERY

    variables = {
      "input": {
        "id": shopify_product_id,
        "price": new_price.to_s
      }
    }

    response = @client.query(query: query, variables: variables)

    if response.body["data"]["productVariantUpdate"]["userErrors"].empty?
      puts "Product price updated successfully for variant #{shopify_product_id}"
    else
      puts "Error updating product price: #{response.body['data']['productVariantUpdate']['userErrors']}"
    end
  end

  def save_variant_to_db(product_id:, shopify_product_id:, shopify_variant_id:, title:, sku:, price:, weight:, weight_unit:)
    Variant.create(
      product_id: product_id,
      shopify_product_id: shopify_product_id,
      shopify_variant_id: shopify_variant_id,
      title: title,
      sku: sku,
      price: price,
      weight: weight,
      weight_unit: weight_unit
    )
  end

  def publish_product_to_store(product_id)
    query = <<~QUERY
      mutation publishablePublish($id: ID!, $input: [PublicationInput!]!) {
        publishablePublish(id: $id, input: $input) {
       
          shop {
            publicationCount
          }
          userErrors {
            field
            message
          }
        }
      }
    QUERY

    variables = {
      "id": product_id,
      "input": {
        "publicationId": FetchPublicationId.instance.fetch_data(@shop_domain, @access_token)
      }
    }

    @client.query(query: query, variables: variables)
  end

end
