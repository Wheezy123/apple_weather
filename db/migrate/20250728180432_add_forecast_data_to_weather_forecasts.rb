class AddForecastDataToWeatherForecasts < ActiveRecord::Migration[7.1]
  def change
    add_column :weather_forecasts, :forecast_data, :text
  end
end
