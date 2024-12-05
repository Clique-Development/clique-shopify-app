class ProductPriceUpdateService
  def initialize(price_setting)
    @price_setting = price_setting
  end

  def perform
    Product.find_in_batches(batch_size: 1000) do |products|
      updates = []

      products.each do |product|
        updates << prepare_product_update(product)
      end

      Product.upsert_all(updates, unique_by: :id)

      enqueue_shopify_updates(products)
    end
  end

  private

  def prepare_product_update(product)
    cost_of_gram = product.unit_weight_gr / 1000
    unit_cost_including_weight_usd = cost_of_gram * @price_setting.cost_of_kg.to_f
    egp_exchange_rate = @price_setting.final_black_market_price.to_f
    unit_cost_egp = product.unit_cost_usd.to_f * egp_exchange_rate
    cost_of_kg = @price_setting.cost_of_kg.to_f
    gross_margin_multiplier = 1 + (@price_setting.gross_margin.to_f / 100)

    final_price = (((((product.unit_cost_usd.to_f + unit_cost_including_weight_usd).round(2)) * egp_exchange_rate).round(2)) * gross_margin_multiplier).round(2)

    {
      id: product.id,
      unit_cost_egp: unit_cost_egp.round(2),
      cost_of_kg: cost_of_kg,
      cost_of_gram: cost_of_kg / 1000,
      unit_cost_including_weight_usd: (product.unit_cost_usd.to_f + unit_cost_including_weight_usd).round(2),
      unit_cost_including_weight_egp: (((product.unit_cost_usd.to_f + unit_cost_including_weight_usd).round(2)) * egp_exchange_rate).round(2),
      gross_margin: @price_setting.gross_margin.to_f,
      final_price: final_price
    }
  end

  def enqueue_shopify_updates(products)
    products.each do |product|
      ShopifySyncJob.perform_async(product.id)
    end
  end
end
