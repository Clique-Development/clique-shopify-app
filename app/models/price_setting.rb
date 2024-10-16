class PriceSetting < ApplicationRecord
  validates :cost_of_kg, :gross_margin, :black_market_egp_markup, numericality: { greater_than_or_equal_to: 0 }
  after_save :update_product_prices

  private

  def update_product_prices
    ProductPriceUpdaterService.new(self).perform
  end
end