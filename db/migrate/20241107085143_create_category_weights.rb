class CreateCategoryWeights < ActiveRecord::Migration[7.0]
  def change
    create_table :category_weights do |t|
      t.string :category
      t.string :subcategory
      t.float :weight

      t.timestamps
    end
  end
end
