class CreateOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :orders do |t|
      t.bigint :shopify_order_id
      t.integer :order_number
      t.string :name
      t.string :email
      t.string :order_status_url
      t.string :cancel_reason
      t.datetime :cancelled_at
      t.string  :cart_token
      t.string  :checkout_id
      t.string  :checkout_token
      t.boolean :confirmed
      t.string :currency
      t.decimal :total_price
      t.decimal :subtotal_price
      t.decimal :current_total_tax
      t.decimal :total_discounts
      t.boolean :fulfillment_status
      t.string :phone
      t.string :tags
      t.string :token
      t.decimal :total_tax
      t.datetime :shopify_created_at
      t.string :note
      t.boolean :is_deleted, default: false

      t.timestamps
    end
  end
end