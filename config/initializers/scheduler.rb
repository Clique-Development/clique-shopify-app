# require 'sidekiq'
# require 'sidekiq-cron'
#
# if Sidekiq.server?
#   Sidekiq::Cron::Job.create(
#     name: 'Fetch Order Status Job - every 30 minutes',
#     cron: '*/30 * * * *',
#     class: 'FetchOrderStatusJob'
#   )
# end
