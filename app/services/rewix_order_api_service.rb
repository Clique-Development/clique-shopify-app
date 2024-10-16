require 'httparty'
require 'base64'

class RewixOrderApiService
  include HTTParty
  base_uri 'https://griffati.rewix.zero11.org/restful'

  def initialize(api_key, password)
    @api_key = api_key
    @password = password

    @headers = {
      'Accept' => 'application/xml',
      'Content-Type' => 'application/xml',
      'Authorization' => "Basic " + Base64.strict_encode64("#{@api_key}:#{@password}")
    }
  end

  # Method to create a dropshipping order
  def create_dropshipping_order(order_data)
    response = self.class.post(
      '/ghost/orders/0/dropshipping',
      headers: @headers,
      body: order_data.to_xml(root: 'order')
    )

    if response.success?
      puts "Order created successfully: #{response.body}"
    else
      raise "Failed to create order: #{response.message}"
    end
  end
end
