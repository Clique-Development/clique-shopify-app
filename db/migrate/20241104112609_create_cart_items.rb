class CreateCartItems < ActiveRecord::Migration[7.0]
  def change
    create_table :cart_items do |t|
      t.bigint :shopify_id
      t.integer :quantity
      t.string :sku
      t.bigint :variant_id
      t.references :cart
      t.timestamps
    end
  end
end
