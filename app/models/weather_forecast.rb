# Manages weather forecast data with intelligent caching capabilities.
#
# This model stores both current weather conditions and extended 5-day forecast data
# with a 30-minute time-to-live (TTL) caching strategy. It handles automatic cache
# expiration and provides convenient methods for cache status checking.
#
# The extended forecast data is stored as JSON and automatically parsed when accessed.
# This approach optimizes API usage while maintaining data freshness.
#
# @example Creating a new forecast
#   forecast = WeatherForecast.create!(
#     zip_code: "78701",
#     current_temperature: 75.0,
#     high_temperature: 85.0,
#     low_temperature: 65.0,
#     description: "partly cloudy",
#     forecast_data: extended_data.to_json,
#     cached_at: Time.current
#   )
#
# @example Retrieving cached forecast
#   cached = WeatherForecast.cached_forecast_for("78701")
#   cached.from_cache? #=> true (if within 30 minutes)
class WeatherForecast < ApplicationRecord
  validates :zip_code, presence: true
  validates :current_temperature, presence: true

  scope :fresh, -> { where('cached_at > ?', 30.minutes.ago) }
  scope :for_zip, ->(zip) { where(zip_code: zip) }

  # Retrieves the most recent cached forecast for a given ZIP code.
  #
  # Only returns forecasts that are still fresh (within 30-minute TTL).
  # Orders by cached_at timestamp to ensure the most recent forecast is returned.
  #
  # @param zip_code [String] the ZIP code to search for
  # @return [WeatherForecast, nil] the most recent fresh forecast or nil if none found
  #
  # @example
  #   forecast = WeatherForecast.cached_forecast_for("90210")
  #   if forecast
  #     puts "Cached temperature: #{forecast.current_temperature}°F"
  #   else
  #     puts "No fresh cache available, need to fetch from API"
  #   end
  def self.cached_forecast_for(zip_code)
    fresh.for_zip(zip_code).order(cached_at: :desc).first
  end

  def cache_expired?
    cached_at < 30.minutes.ago
  end

  def from_cache?
    persisted? && !cache_expired?
  end

  def extended_forecast
    return [] unless forecast_data.present?

    JSON.parse(forecast_data)
  end
end
