class FetchOrderStatusJob < ApplicationJob
  queue_as :default

  STATUS_CODE_TO_FINANCIAL_STATUS = {
    0 => 'pending',
    1 => 'money_waiting',
    2 => 'to_dispatch',
    3 => 'dispatched',
    5 => 'booked',
    2000 => 'cancelled',
    2002 => 'verify_failed',
    3001 => 'working_on',
    3002 => 'ready',
    5003 => 'dropshipper_growing'
  }.freeze

  def perform
    orders_with_rewix_id = Order.where.not(rewix_id: nil)

    orders_with_rewix_id.find_each do |order|
      begin
        rewix_service = RewixOrderApiService.new('272000ec-9039-4c4e-a874-6dd5ea741b31', 'Cliqueadmin1')
        response = rewix_service.fetch_order_status(order.rewix_id)

        if response.success?
          response_data = response.parsed_response['orders']
          if response_data.present?
            response_data.each do |order_data|
              status_code = order_data['status']
              financial_status = STATUS_CODE_TO_FINANCIAL_STATUS[status_code]

              if financial_status
                order.update!(financial_status: financial_status)
                Rails.logger.info("Updated financial status for Order ID #{order.id} (Rewix ID #{order.rewix_id}) to '#{financial_status}'")
              else
                Rails.logger.warn("Unknown status code #{status_code} for Order ID #{order.id} (Rewix ID #{order.rewix_id})")
              end
            end
          else
            Rails.logger.error("No orders found in the response for Order ID #{order.id} (Rewix ID #{order.rewix_id})")
          end
        else
          Rails.logger.error("Failed to fetch order status for Order ID #{order.id} (Rewix ID #{order.rewix_id}): #{response.message}")
        end
      rescue => e
        Rails.logger.error("Exception while fetching order status for Order ID #{order.id} (Rewix ID #{order.rewix_id}): #{e.message}")
      end
    end
  end
end
