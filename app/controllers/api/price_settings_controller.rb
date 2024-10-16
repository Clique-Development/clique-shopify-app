class Api::PriceSettingsController < ActionController::API
  def calculate_final_black_market_price
    cost_of_kg = params[:costOfKg].to_f
    gross_margin = params[:grossMargin].to_f
    black_market_egp_markup = params[:blackmarket].to_f
    currency_exchange = EgpCurrencyExchange.new('fe7edc96e8f3ba3cb979e3e704231ebd')
    egp_rate = currency_exchange.convert(1, 'USD', 'EGP')
    final_black_market_price = (egp_rate + black_market_egp_markup).round(2)

    price_setting = PriceSetting.last
    if price_setting.present?
      price_setting.update(cost_of_kg: cost_of_kg, gross_margin: gross_margin, black_market_egp_markup: black_market_egp_markup, final_black_market_price: final_black_market_price)
    else
      PriceSetting.create(cost_of_kg: cost_of_kg, gross_margin: gross_margin, black_market_egp_markup: black_market_egp_markup, final_black_market_price: final_black_market_price)
    end

    render json: { finalPrice: final_black_market_price }, status: :ok
  end
end