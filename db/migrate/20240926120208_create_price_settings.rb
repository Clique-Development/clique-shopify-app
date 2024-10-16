class CreatePriceSettings < ActiveRecord::Migration[7.0]
  def change
    create_table :price_settings do |t|
      t.decimal :cost_of_kg
      t.decimal :gross_margin
      t.decimal :black_market_egp_markup
      t.decimal :final_black_market_price

      t.timestamps
    end
  end
end
