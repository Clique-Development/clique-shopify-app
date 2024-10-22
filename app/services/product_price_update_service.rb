class ProductPriceUpdateService
  def initialize(price_setting)
    @price_setting = price_setting
  end

  def perform
    Product.find_each do |product|
      update_product_price(product)
    end
  end

  private

  def update_product_price(product)
    cost_of_gram = product.unit_weight_gr / 1000
    unit_cost_including_weight_usd = cost_of_gram * @price_setting.cost_of_kg.to_f
    unit_cost_including_weight_egp = @price_setting.cost_of_kg.to_f * @price_setting.final_black_market_price.to_f
    final_price = unit_cost_including_weight_egp + (unit_cost_including_weight_egp * @price_setting.gross_margin.to_f)

    product.update!(
      unit_cost_including_weight_usd: unit_cost_including_weight_usd.round(2),
      unit_cost_including_weight_egp: unit_cost_including_weight_egp.round(2),
      final_price: final_price.round(2)
    )

    shopify_service = ShopifyProductService.new(product.shop.shopify_domain, product.shop.shopify_token)
    shopify_service.update_product_price(product.shopify_product_id, product.final_price)
  end
end
