class SyncProductsDailyJob
  include Sidekiq::Job

  def perform(*args)
    id = Shop.last&.id
    return unless id

    SyncProductsJob.perform_async(id)
  end
end
