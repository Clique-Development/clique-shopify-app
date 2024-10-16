require 'net/http'
require 'json'

class EgpCurrencyExchange
  BASE_URL = "http://data.fixer.io/api/latest" # Adjust this based on your service provider

  def initialize(api_key)
    @api_key = api_key
  end

  def fetch_rates
    uri = URI("#{BASE_URL}?access_key=#{@api_key}")
    response = Net::HTTP.get(uri)
    JSON.parse(response)
  rescue => e
    puts "Error fetching rates: #{e.message}"
    nil
  end

  def convert(amount, from_currency, to_currency)
    rates = fetch_rates
    return "Failed to fetch rates." unless rates

    # Debugging output to inspect rates
    puts "Fetched rates: #{rates.inspect}"

    unless rates["rates"] && rates["rates"].key?(from_currency) && rates["rates"].key?(to_currency)
      return "Currency conversion not available for #{from_currency} or #{to_currency}."
    end

    conversion_rate = rates["rates"][to_currency] / rates["rates"][from_currency]
    converted_amount = amount * conversion_rate

    converted_amount
  end
end
