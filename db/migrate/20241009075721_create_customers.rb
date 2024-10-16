class CreateCustomers < ActiveRecord::Migration[7.0]
  def change
    create_table :customers do |t|
      t.bigint  :shopify_customer_id
      t.string  :email
      t.boolean :accepts_marketing
      t.string  :first_name
      t.string  :last_name
      t.integer :orders_count
      t.string  :state
      t.decimal :total_spent
      t.integer :last_order_id
      t.text    :note
      t.boolean :verified_email
      t.string  :multipass_identifier
      t.boolean :tax_exempt
      t.string  :tags
      t.string  :last_order_name
      t.string  :currency
      t.string  :phone
      t.boolean :is_deleted, default: false
      t.datetime :shopify_created_at
      t.datetime :shopify_updated_at

      t.timestamps
    end
  end
end
