class WeatherForecast < ApplicationRecord
  validates :zip_code, presence: true
  validates :current_temperature, presence: true

  scope :fresh, -> { where('cached_at > ?', 30.minutes.ago) }
  scope :for_zip, ->(zip) { where(zip_code: zip) }

  def self.cached_forecast_for(zip_code)
    fresh.for_zip(zip_code).order(cached_at: :desc).first
  end

  def cache_expired?
    cached_at < 30.minutes.ago
  end

  def from_cache?
    persisted? && !cache_expired?
  end
end
