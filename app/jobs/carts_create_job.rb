class CartsCreateJob < ActiveJob::Base
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
      cart_data = JSON.parse(webhook_data.to_json) if webhook_data.is_a?(Hash)

      line_items = cart_data['line_items']
      models_data = line_items.map do |item|
        {
          stock_id: item['sku'],
          quantity: item['quantity']
        }
      end
      operations = {
        operations: [
          type: 'lock',
          models: models_data
        ]
      }

      rewix_service = RewixApiService.new('272000ec-9039-4c4e-a874-6dd5ea741b31', 'Cliqueadmin1')
      rewix_service.lock_quantity(operations)
    end
  end
end

  # {:operations=>[{:type=>"lock", :models=>[{:stock_id=>"449663", :quantity=>1}]}]}