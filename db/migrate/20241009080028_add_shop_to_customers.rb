class AddShopToCustomers < ActiveRecord::Migration[7.0]
  def change
    add_reference :customers, :shop
  end
end
