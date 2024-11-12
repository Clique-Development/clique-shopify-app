ShopifyApp.configure do |config|
  config.application_name = "My Shopify App"
  config.old_secret = ""
  config.scope = "read_products,read_orders,read_customers,read_inventory,read_fulfillments,write_products,write_orders,write_inventory, read_publications"
  config.embedded_app = true
  config.after_authenticate_job = false
  config.api_version = "2024-01"
  config.shop_session_repository = 'Shop'
  config.log_level = :info
  config.reauth_on_access_scope_changes = true
  config.webhooks = [
    { topic: "orders/create", path: "webhooks/orders_create" },
    { topic: "carts/create", path: "webhooks/carts_create" },
    { topic: "carts/update", path: "webhooks/carts_update" },
    { topic: "app/uninstalled", address: "webhooks/app_uninstalled"},
    { topic: "customers/data_request", address: "webhooks/customers_data_request" },
    { topic: "customers/redact", address: "webhooks/customers_redact"},
    { topic: "shop/redact", address: "webhooks/shop_redact"}
  ]

  config.api_key = ENV.fetch('SHOPIFY_API_KEY', '').presence
  config.secret = ENV.fetch('SHOPIFY_API_SECRET', '').presence

  # You may want to charge merchants for using your app. Setting the billing configuration will cause the Authenticated
  # controller concern to check that the session is for a merchant that has an active one-time payment or subscription.
  # If no payment is found, it starts off the process and sends the merchant to a confirmation URL so that they can
  # approve the purchase.
  #
  # Learn more about billing in our documentation: https://shopify.dev/apps/billing
  # config.billing = ShopifyApp::BillingConfiguration.new(
  #   charge_name: "My app billing charge",
  #   amount: 5,
  #   interval: ShopifyApp::BillingConfiguration::INTERVAL_EVERY_30_DAYS,
  #   currency_code: "USD", # Only supports USD for now
  #   trial_days: 0
  #   test: ENV.fetch('SHOPIFY_TEST_CHARGES', !Rails.env.production?)
  # )

  if defined? Rails::Server
    raise('Missing SHOPIFY_API_KEY. See https://github.com/Shopify/shopify_app#requirements') unless config.api_key
    raise('Missing SHOPIFY_API_SECRET. See https://github.com/Shopify/shopify_app#requirements') unless config.secret
  end
end

Rails.application.config.after_initialize do
  if ShopifyApp.configuration.api_key.present? && ShopifyApp.configuration.secret.present?
    ShopifyAPI::Context.setup(
      api_key: ShopifyApp.configuration.api_key,
      api_secret_key: ShopifyApp.configuration.secret,
      api_version: ShopifyApp.configuration.api_version,
      host: ENV['HOST'],
      scope: ShopifyApp.configuration.scope,
      is_private: !ENV.fetch('SHOPIFY_APP_PRIVATE_SHOP', '').empty?,
      is_embedded: ShopifyApp.configuration.embedded_app,
      log_level: :info,
      logger: Rails.logger,
      private_shop: ENV.fetch('SHOPIFY_APP_PRIVATE_SHOP', nil),
      user_agent_prefix: "ShopifyApp/#{ShopifyApp::VERSION}"
    )

    ShopifyApp::WebhooksManager.add_registrations
  end
end
