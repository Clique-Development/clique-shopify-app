class AddShopToProduct < ActiveRecord::Migration[7.0]
  def change
    add_reference :products, :shop
  end
end