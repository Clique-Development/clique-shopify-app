module WebhooksConcern
  extend ActiveSupport::Concern

  included do

    WEBHOOKS = ['app/uninstalled', 'customers/create', 'customers/delete', 'customers/update', 'inventory_levels/update',
                'orders/cancelled', 'orders/create', 'orders/updated', 'products/create', 'products/delete',
                'products/update', 'shop/update'
    ]

    def create_webhooks
      ShopifyAPI::Auth::Session.temp(shop: shopify_domain, access_token: shopify_token) do
        delete_webhooks
        add_webhook
      end

    end

    def add_webhook
      Shop::WEBHOOKS.each do |topic|
        webhook = ShopifyAPI::Webhook.new()
        webhook.topic = topic
        webhook.address = "#{ENV.fetch('HOST', '')}/webhooks/#{topic.gsub('/', '_')}"
        webhook.format = "json"
        webhook.save!
      end
    end

    def delete_webhooks
      ShopifyAPI::Webhook.all.each do |webhook|
        webhook.delete
      end
    end
  end
end
