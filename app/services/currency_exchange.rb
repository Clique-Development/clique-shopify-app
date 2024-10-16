require 'money'
require 'eu_central_bank'

class CurrencyExchange
  def initialize
    @bank = EuCentralBank.new
    # Download the latest exchange rates (can be cached for future use)
    @bank.update_rates
    Money.default_bank = @bank
  end

  # Method to convert currency from one to another
  def convert(amount, from_currency, to_currency)
    money = Money.new(amount * 100, from_currency) # Convert amount to cents
    money.exchange_to(to_currency)
  rescue Money::Bank::UnknownRate => e
    "Error: #{e.message}"
  end
end
