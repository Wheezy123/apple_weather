class CreateWeatherForecasts < ActiveRecord::Migration[7.1]
  def change
    create_table :weather_forecasts do |t|
      t.string :zip_code
      t.decimal :current_temperature
      t.decimal :high_temperature
      t.decimal :low_temperature
      t.string :description
      t.datetime :cached_at

      t.timestamps
    end
  end
end
