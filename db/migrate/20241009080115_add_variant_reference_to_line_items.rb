class AddVariantReferenceToLineItems < ActiveRecord::Migration[7.0]
  def change
    add_column :line_items, :shopify_variant_id, :bigint
  end
end
