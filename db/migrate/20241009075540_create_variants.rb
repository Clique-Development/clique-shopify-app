class CreateVariants < ActiveRecord::Migration[7.0]
  def change
    create_table :variants do |t|
      t.bigint  :shopify_variant_id
      t.bigint  :shopify_product_id
      t.string  :title
      t.decimal :price
      t.string  :sku
      t.integer :position
      t.string  :inventory_policy
      t.decimal :compare_at_price
      t.string  :fulfillment_service
      t.string  :inventory_management
      t.boolean :taxable, default: false
      t.string  :barcode
      t.integer :grams
      t.bigint  :image_id
      t.decimal :weight
      t.string  :weight_unit
      t.bigint  :inventory_item_id
      t.integer :inventory_quantity
      t.integer :old_inventory_quantity
      t.boolean :requires_shipping, default: false
      t.string  :admin_graphql_api_id
      t.datetime  :shopify_created_at
      t.datetime  :shopify_updated_at
      t.references :product

      t.timestamps
    end
  end
end
