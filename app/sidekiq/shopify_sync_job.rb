class ShopifySyncJob
  include Sidekiq::Job

  def perform(product_id)
    product = Product.find(product_id)
    shopify_service = ShopifyProductService.new(product.shop.shopify_domain, product.shop.shopify_token)
    shopify_service.update_product_price(product.shopify_product_id, product.final_price)
  end
end
