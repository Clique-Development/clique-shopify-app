class Shop < ApplicationRecord
  include ShopifyApp::ShopSessionStorageWithScopes
  include WebhooksConcern

  has_many :products, dependent: :destroy
  has_many :variants, through: :products
  has_many :orders, dependent: :destroy
  has_many :customers, dependent: :destroy
  # after_create :create_webhooks

  def api_version
    ShopifyApp.configuration.api_version
  end

  def retrieve_session
    @session ||= ShopifyAPI::Auth::Session.new(shop: shopify_domain, access_token: shopify_token)
  end
end
