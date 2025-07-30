# Service object for integrating with OpenWeatherMap API endpoints.
#
# This service handles communication with both current weather and extended forecast
# APIs from OpenWeatherMap. It provides a clean interface for weather data retrieval,
# error handling, and data transformation suitable for application consumption.
#
# The service uses HTTParty for HTTP requests and includes automatic JSON parsing
# and error handling. Extended forecast data is aggregated from 3-hour intervals
# into daily summaries for improved user experience.
#
# @example Basic usage for current weather
#   service = WeatherService.new
#   weather = service.current_weather_by_zip("78701")
#   puts "Current temperature: #{weather[:current_temperature]}°F"
#
# @example Getting extended forecast
#   service = WeatherService.new
#   forecast = service.extended_forecast_by_zip("90210")
#   forecast.each do |day|
#     puts "#{day[:date]}: #{day[:high_temperature]}°F / #{day[:low_temperature]}°F"
#   end
class WeatherService
  include HTTParty
  base_uri 'http://api.openweathermap.org/data/2.5'

  def initialize(api_key = ENV['OPENWEATHER_API_KEY'])
    @api_key = api_key
  end

  # Retrieves current weather conditions for a given ZIP code.
  #
  # Makes a request to OpenWeatherMap's current weather endpoint and returns
  # structured weather data including temperature, daily high/low, and conditions.
  # All temperature values are returned in Fahrenheit.
  #
  # @param zip_code [String] 5-digit US ZIP code
  # @return [Hash] weather data with keys:
  #   - :current_temperature [Float] current temperature in Fahrenheit
  #   - :high_temperature [Float] daily high temperature in Fahrenheit
  #   - :low_temperature [Float] daily low temperature in Fahrenheit
  #   - :description [String] weather condition description
  # @raise [StandardError] if API request fails or returns error status
  #
  # @example
  #   service = WeatherService.new
  #   weather = service.current_weather_by_zip("78701")
  #   #=> {
  #   #     current_temperature: 75.2,
  #   #     high_temperature: 85.1,
  #   #     low_temperature: 65.3,
  #   #     description: "partly cloudy"
  #   #   }
  def current_weather_by_zip(zip_code)
    response = get('/weather', query: {
                     zip: zip_code,
                     appid: @api_key,
                     units: 'imperial'
                   })

    handle_response(response)
  end

  # Retrieves 5-day extended weather forecast for a given ZIP code.
  #
  # Makes a request to OpenWeatherMap's forecast endpoint and aggregates the
  # 3-hour interval forecasts into daily summaries. Each day shows the high/low
  # temperatures and representative weather condition.
  #
  # @param zip_code [String] 5-digit US ZIP code
  # @return [Array<Hash>] array of daily forecast hashes, each containing:
  #   - :date [String] forecast date in YYYY-MM-DD format
  #   - :high_temperature [Float] daily high temperature in Fahrenheit
  #   - :low_temperature [Float] daily low temperature in Fahrenheit
  #   - :description [String] weather condition description for the day
  # @raise [StandardError] if API request fails or returns error status
  #
  # @example
  #   service = WeatherService.new
  #   forecast = service.extended_forecast_by_zip("90210")
  #   #=> [
  #   #     { date: "2024-03-15", high_temperature: 78.0, low_temperature: 62.0, description: "sunny" },
  #   #     { date: "2024-03-16", high_temperature: 75.0, low_temperature: 58.0, description: "cloudy" },
  #   #     ...
  #   #   ]
  def extended_forecast_by_zip(zip_code)
    response = get('/forecast', query: {
                     zip: zip_code,
                     appid: @api_key,
                     units: 'imperial'
                   })

    handle_forecast_response(response)
  end

  private

  def get(path, options = {})
    self.class.get(path, options)
  end

  def handle_response(response)
    raise StandardError, "Weather API error: #{response.code} #{response.message}" unless response.success?

    weather_data = response.parsed_response
    {
      current_temperature: weather_data['main']['temp'],
      high_temperature: weather_data['main']['temp_max'],
      low_temperature: weather_data['main']['temp_min'],
      description: weather_data['weather'][0]['description']
    }
  end

  # Processes extended forecast API response and aggregates into daily summaries.
  #
  # Takes the array of 3-hour forecasts via OpenWeatherMap and groups them by date, then calculates
  # daily high/low temperatures and selects representative weather description.
  #
  # @param response [HTTParty::Response] HTTP response from forecast endpoint
  # @return [Array<Hash>] array of daily forecast summaries
  # @raise [StandardError] if response indicates API error
  def handle_forecast_response(response)
    raise StandardError, "Forecast API error: #{response.code} #{response.message}" unless response.success?

    forecast_data = response.parsed_response
    daily_forecasts = group_forecasts_by_day(forecast_data['list'])

    daily_forecasts.map do |date, forecasts|
      temps = forecasts.map { |f| f['main']['temp'] }
      {
        date: date,
        high_temperature: temps.max,
        low_temperature: temps.min,
        description: forecasts.first['weather'][0]['description']
      }
    end
  end

  # Groups forecast data points by calendar date.
  #
  # Takes the raw forecast list (3-hour intervals via OpenWeatherMap) and groups them by date string.
  # This is needed for daily aggregation of temperature and weather data.
  #
  # @param forecast_list [Array<Hash>] array of forecast data points
  # @return [Hash] hash with date strings as keys and forecast arrays as values
  def group_forecasts_by_day(forecast_list)
    forecast_list.group_by do |forecast|
      Time.at(forecast['dt']).strftime('%Y-%m-%d')
    end
  end
end
