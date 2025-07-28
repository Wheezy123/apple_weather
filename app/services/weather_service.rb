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
end