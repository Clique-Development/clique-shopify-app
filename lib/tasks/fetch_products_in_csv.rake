namespace :fetch_data do
  desc 'Fetch products from api'
  task products: :environment do
    require 'csv'

    csv_file_path = "products.csv"

    CSV.open(csv_file_path, "wb") do |csv|
      csv << ["Product Image", "Category", "Subcategory", "Product Item", "Actual Weight Item"]

      rewix_service = RewixApiService.new('272000ec-9039-4c4e-a874-6dd5ea741b31', 'Cliqueadmin1')
      fetched_products = rewix_service.fetch_products
      parsed_products = JSON.parse(fetched_products)["pageItems"]

      count = 0
      parsed_products.each do |product|
        category_tag = product["tags"].find { |tag| tag["name"] == "category" }
        category = category_tag&.dig('value', 'value')
        subcategory_tag = product["tags"].find { |tag| tag["name"] == "subcategory" }
        subcategory = subcategory_tag&.dig('value', 'value')
        images_url = product['images']&.map { |item| "https://griffati.rewix.zero11.org/#{item['url']}" }.join(',')
        product_item = product['name']

        csv << [images_url, category, subcategory, product_item, '']

        puts "Product Added: #{count}"
        count += 1
      end
    end

    puts "Products data has been written to #{csv_file_path}"

  end
end
