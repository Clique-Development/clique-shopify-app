# lib/tasks/import_weights.rake
require 'csv'

namespace :import do
  desc "Import category weights from CSV file"
  task weights: :environment do
    file_path = "/home/southville/Downloads/products_with_weights_category.csv"

    CSV.foreach(file_path, headers: true) do |row|
      category = row['Category']
      subcategory = row['Subcategory']
      weight = row['Actual Weight Item'].to_f

      CategoryWeight.find_or_create_by(category: category, subcategory: subcategory) do |record|
        record.weight = weight
      end
    end

    puts "Category weights have been imported successfully."
  end
end