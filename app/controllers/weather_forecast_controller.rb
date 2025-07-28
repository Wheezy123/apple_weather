class WeatherForecastController < ApplicationController
  def index
    @address = Address.new
    @forecast = nil
    @from_cache = false
  end

  def create
    @address = Address.new(address_params)
    @forecast = nil
    @from_cache = false
    
    if @address.valid? && @address.save
      zip_code = @address.zip_code
      
      cached_forecast = WeatherForecast.cached_forecast_for(zip_code)
      
      if cached_forecast
        @forecast = cached_forecast
        @from_cache = true
      else
        @forecast = fetch_and_cache_weather(zip_code)
        @from_cache = false
        
        unless @forecast
          flash.now[:error] = "Unable to retrieve weather data. Please try again later."
        end
      end
      
      render :index
    else
      @forecast = nil
      @from_cache = false
      render :index
    end
  end

  private

  def address_params
    params.require(:address).permit(:street_address, :city, :state, :zip_code)
  end

  def fetch_and_cache_weather(zip_code)
    weather_service = WeatherService.new
    weather_data = weather_service.current_weather_by_zip(zip_code)
    extended_forecast_data = weather_service.extended_forecast_by_zip(zip_code)
    
    return nil unless weather_data
    
    WeatherForecast.create!(
      zip_code: zip_code,
      current_temperature: weather_data[:current_temperature],
      high_temperature: weather_data[:high_temperature],
      low_temperature: weather_data[:low_temperature],
      description: weather_data[:description],
      forecast_data: extended_forecast_data.to_json,
      cached_at: Time.current
    )
  rescue => e
    Rails.logger.error "Weather fetch error for ZIP #{zip_code}: #{e.message}"
    Rails.logger.error e.backtrace.join("\n") if Rails.env.development?
    nil
  end
end
