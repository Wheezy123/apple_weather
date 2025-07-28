class WeatherService
  include HTTParty
  base_uri 'http://api.openweathermap.org/data/2.5'

  def initialize(api_key = ENV['OPENWEATHER_API_KEY'])
    @api_key = api_key
  end

  def current_weather_by_zip(zip_code)
    response = get('/weather', query: {
      zip: zip_code,
      appid: @api_key,
      units: 'imperial'
    })

    handle_response(response)
  end

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
    if response.success?
      weather_data = response.parsed_response
      {
        current_temperature: weather_data['main']['temp'],
        high_temperature: weather_data['main']['temp_max'],
        low_temperature: weather_data['main']['temp_min'],
        description: weather_data['weather'][0]['description']
      }
    else
      raise StandardError, "Weather API error: #{response.code} #{response.message}"
    end
  end

  def handle_forecast_response(response)
    if response.success?
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
    else
      raise StandardError, "Forecast API error: #{response.code} #{response.message}"
    end
  end

  def group_forecasts_by_day(forecast_list)
    forecast_list.group_by do |forecast|
      Time.at(forecast['dt']).strftime('%Y-%m-%d')
    end
  end
end
