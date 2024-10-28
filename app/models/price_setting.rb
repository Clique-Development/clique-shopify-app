class PriceSetting < ApplicationRecord
  validates :cost_of_kg, :gross_margin, :black_market_egp_markup, numericality: { greater_than_or_equal_to: 0 }
  after_update :update_product_prices, if: :price_present?

  private

  def update_product_prices
    # ProductPriceUpdateService.new(self).perform
  end

  def price_present?
    cost_of_kg.present? && gross_margin.present? && black_market_egp_markup.present? && final_black_market_price.present?
  end
end