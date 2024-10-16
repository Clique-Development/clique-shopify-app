class AddShopToOrders < ActiveRecord::Migration[7.0]
  def change
    add_reference :orders, :shop
  end
end
