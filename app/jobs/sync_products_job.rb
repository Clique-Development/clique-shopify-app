class SyncProductsJob < ApplicationJob
  queue_as :default

  def perform
    # Call sync_products logic here
  end
end