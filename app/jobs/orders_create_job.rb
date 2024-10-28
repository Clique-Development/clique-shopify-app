class OrdersCreateJob < ActiveJob::Base
  extend ShopifyAPI::Webhooks::Handler

  class << self
    def handle(topic:, shop:, body:)
      perform_later(topic: topic, shop_domain: shop, webhook: body)
    end
  end

  def perform(topic:, shop_domain:, webhook:)
    shop = Shop.find_by(shopify_domain: shop_domain)

    if shop.nil?
      logger.error("#{self.class} failed: cannot find shop with domain '#{shop_domain}'")
      raise ActiveRecord::RecordNotFound, "Shop Not Found"
    end

    shop.with_shopify_session do |session|
      webhook_data = webhook.is_a?(ActionController::Parameters) ? webhook.to_unsafe_h : webhook
      order_data = JSON.parse(webhook_data.to_json) if webhook_data.is_a?(Hash)

      create_order(order_data, shop)
    end
  end

  private

  def create_order(order_data, shop)
    order_attributes = {
      shop: shop,
      shopify_order_id: order_data["id"],
      order_number: order_data["order_number"],
      name: order_data["name"],
      email: order_data["contact_email"],
      order_status_url: order_data["order_status_url"],
      cancel_reason: order_data["cancel_reason"],
      cancelled_at: order_data["cancelled_at"],
      cart_token: order_data["cart_token"],
      checkout_id: order_data["checkout_id"],
      checkout_token: order_data["checkout_token"],
      confirmed: order_data["confirmed"],
      currency: order_data["currency"],
      total_price: order_data["total_price"].to_f,
      subtotal_price: order_data["subtotal_price"].to_f,
      current_total_tax: order_data["total_tax"].to_f,
      total_discounts: order_data["total_discounts"].to_f,
      fulfillment_status: order_data["fulfillment_status"],
      financial_status: order_data["financial_status"],
      cost_of_dropshipping: 9.8,
      phone: order_data["phone"],
      tags: order_data["tags"],
      token: order_data["token"],
      total_tax: order_data["total_tax"].to_f,
      shopify_created_at: order_data["created_at"],
      note: order_data["note"],
      is_deleted: order_data["is_deleted"],
      created_at: Time.current,
      updated_at: Time.current
    }

    order = Order.new(order_attributes)
    create_line_items(order, order_data['line_items'])
    create_customer(order, order_data['customer'])

    if order.save
      logger.info("Order #{order.shopify_order_id} created successfully.")
      update_shipping_address(order.shopify_order_id, shop)

      address = save_address(order.id)
      send_order_to_rewix(order, address) if address
    else
      logger.error("Failed to create order: #{order.errors.full_messages.join(", ")}")
    end
  end

  def create_line_items(order, line_items)
    line_items.each do |line_item|
      item = order.line_items.new(
        shopify_id: line_item['id'],
        name: line_item['name'],
        title: line_item['title'],
        price: line_item['price'],
        shopify_product_id: line_item['product_id'],
        shopify_variant_id: line_item['variant_id'],
        quantity: line_item['quantity'],
        sku: line_item['sku'],
        variant_title: line_item['variant_title']
      )
      item.product = Product.find_by(shopify_product_id: line_item['product_id'])
      item.variant = Variant.find_by(shopify_variant_id: line_item['variant_id'])
    end
  end

  def create_customer(order, customer_data)
    return unless customer_data

    customer_id = customer_data['id']
    existing_customer = Customer.find_by(shopify_customer_id: customer_id)
    if existing_customer
      order.customer_id = existing_customer.id
    else
      customer = Customer.create(
        shopify_customer_id: customer_id,
        first_name: customer_data['first_name'],
        last_name: customer_data['last_name'],
        email: customer_data['email'],
        phone: customer_data['phone'],
        state: customer_data['state'],
        currency: customer_data['currency'],
        shopify_created_at: customer_data['created_at'],
        shopify_updated_at: customer_data['updated_at']
      )
      order.customer_id = customer.id
    end
  end

  def save_address(order_id)
    address_attributes = {
      first_name: "Aly",
      last_name: "Dabbous",
      company: "",
      address1: "EuroLanes, via del Gaggiolo, 38",
      address2: "CAI815724",
      city: "Arcene",
      province: "Bergamo",
      country: "Italy",
      zip: "24040",
      phone: "0039 035 418 5292",
      name: "Aly Dabbous",
      province_code: "",
      country_code: "IT",
      country_name: "Italy",
      address_type: "billing",
      latitude: nil,
      longitude: nil,
      is_deleted: false,
      order_id: order_id,
      created_at: Time.current,
      updated_at: Time.current
    }

    address = Address.new(address_attributes)

    if address.save
      logger.info("Address for order #{order_id} created successfully.")
      return address
    else
      logger.error("Failed to create address: #{address.errors.full_messages.join(", ")}")
    end
  end

  def send_order_to_rewix(order, address)
    order.line_items.each do |line_item|
      rewix_order_data = {
        key: order.shopify_order_id,
        date: order.shopify_created_at.strftime("%Y/%m/%d %H:%M:%S %z"),
        recipient: address.name,
        careof: "",
        street_name: address.address1,
        address_number: address.address2,
        zip: address.zip,
        city: address.city,
        province: address.province,
        countrycode: address.country_code,
        prefix: "",
        number: address.phone,
        stock_id: line_item.sku,
        quantity: 1,
        autoConfirm: true
      }
      rewix_service = RewixOrderApiService.new('272000ec-9039-4c4e-a874-6dd5ea741b31', 'Cliqueadmin1')

      begin
        rewix_service.create_dropshipping_order(rewix_order_data)
      rescue => e
        logger.error(e.message)
      end
    end
  end

  def update_shipping_address(order_id, shop)
    shipping_address_mutation = <<-'GRAPHQL'
     mutation($orderId: ID!, $shippingAddress: MailingAddressInput!) {
       orderUpdate(input: { id: $orderId, shippingAddress: $shippingAddress }) {
         order {
           id
           shippingAddress {
             address1
             city
             province
             zip
             country
           }
         }
         userErrors {
           field
           message
         }
       }
     }
    GRAPHQL
    variables = {
      orderId: "gid://shopify/Order/#{order_id}",
      shippingAddress: {
        address1: "EuroLanes, via del Gaggiolo, 38",
        address2: "CAI 815724",
        city: "Arcene",
        province: "Bergamo",
        provinceCode: "BG",
        zip: "24040",
        country: "Italy",
        countryCode: "IT",
        firstName: "Aly",
        lastName: "Dabbous",
        phone: "0039 035 418 5292"
      }
    }
    client = ShopifyAPI::Clients::Graphql::Admin.new(session: shop.retrieve_session)
    client.query(query: shipping_address_mutation, variables: variables)
  end
end
