class UpdateOrders < ActiveRecord::Migration[7.0]
  def change
    add_index :orders, :shopify_order_id, unique: true
    add_column :orders, :rewix_id, :bigInt
  end
end
