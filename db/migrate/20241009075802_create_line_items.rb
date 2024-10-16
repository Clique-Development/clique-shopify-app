class CreateLineItems < ActiveRecord::Migration[7.0]
  def change
    create_table :line_items do |t|
      t.bigint :shopify_id
      t.string :name
      t.string :title
      t.decimal :price
      t.bigint :shopify_product_id
      t.integer :fulfillable_quantity
      t.string :fulfillment_status
      t.integer :quantity
      t.string :sku
      t.decimal :total_discount
      t.bigint :variant_id
      t.string :variant_title
      t.string :vendor
      t.boolean :requires_shipping
      t.references :order

      t.timestamps
    end
  end
end
