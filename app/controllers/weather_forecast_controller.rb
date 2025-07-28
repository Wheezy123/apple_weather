# Controller responsible for handling weather forecast requests and responses.
#
# This controller orchestrates the weather data retrieval process, including
# address validation, cache management, API integration, and error handling.
# It implements an intelligent caching strategy to minimize external API calls
# while ensuring data freshness.
#
# The controller handles both the initial form display and form submission,
# automatically checking for cached data before making external API requests.
# It displays current weather conditions and extended 5-day forecasts with
# clear cache indicators for transparency.
#
# @example Successful weather request flow
#   1. User submits address form via POST /weather_forecast
#   2. Controller validates address data
#   3. System checks for fresh cached forecast by ZIP code
#   4. If cache miss: fetches from OpenWeatherMap APIs
#   5. Displays weather data with cache status indicator
#
# @example Error handling scenarios
#   - Invalid address: shows validation errors on form
#   - API failure: displays user-friendly error message
#   - Network timeout: logs error and shows fallback message
class WeatherForecastController < ApplicationController

  # GET /
  # Displays the weather forecast form with empty address object.
  #
  # Initializes instance variables for the address input form and
  # weather display. Sets up the initial state for the view template.
  #
  # @return [void] renders the index template
  #
  # @example Accessing the weather form
  #   GET http://localhost:3000/
  #   # Displays form with empty address fields
  def index
    @address = Address.new
    @forecast = nil
    @from_cache = false
  end

  # POST /weather_forecast
  # Processes weather forecast requests from the address form.
  #
  # Validates the submitted address data, checks for cached weather data,
  # and either retrieves cached results or fetches fresh data from the API.
  # Handles validation errors and API failures gracefully with appropriate
  # user feedback.
  #
  # @return [void] renders the index template with weather data or errors
  #
  # @example Successful request
  #   POST /weather_forecast
  #   params: {
  #     address: {
  #       street_address: "123 Main St",
  #       city: "Austin",
  #       state: "TX",
  #       zip_code: "78701"
  #     }
  #   }
  #   # Results in weather display with cache indicator
  #
  # @example Invalid address request
  #   POST /weather_forecast
  #   params: { address: { street_address: "", city: "Austin", state: "TX", zip_code: "78701" } }
  #   # Results in form redisplay with validation errors
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

  # Sanitizes and permits address parameters from form submission.
  #
  # Uses Rails strong parameters to ensure only expected address fields
  # are accepted from user input, preventing mass assignment vulnerabilities.
  #
  # @return [ActionController::Parameters] permitted address parameters
  def address_params
    params.require(:address).permit(:street_address, :city, :state, :zip_code)
  end

  # Fetches weather data from external APIs and caches the results.
  #
  # Coordinates with WeatherService to retrieve both current weather conditions
  # and extended forecast data. Creates a new WeatherForecast record with
  # current timestamp for cache management. Includes comprehensive error
  # handling with logging for debugging purposes.
  #
  # @param zip_code [String] 5-digit ZIP code for weather lookup
  # @return [WeatherForecast, nil] cached weather forecast record or nil on failure
  #
  # @example Successful cache operation
  #   forecast = fetch_and_cache_weather("78701")
  #   forecast.current_temperature #=> 75.2
  #   forecast.from_cache? #=> false (newly fetched)
  #
  # @example API failure handling
  #   forecast = fetch_and_cache_weather("invalid_zip")
  #   forecast #=> nil
  #   # Error logged to Rails.logger with full backtrace
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
