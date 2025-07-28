FactoryBot.define do
  factory :weather_forecast do
    zip_code { "78701" }
    current_temperature { 75.0 }
    high_temperature { 85.0 }
    low_temperature { 65.0 }
    description { "partly cloudy" }
    forecast_data { sample_forecast_data }
    cached_at { Time.current }

    trait :expired do
      cached_at { 1.hour.ago }
    end

    trait :fresh do
      cached_at { 10.minutes.ago }
    end

  end
end

def sample_forecast_data
  [
    { date: Time.current.strftime('%Y-%m-%d'), high_temperature: 80.0, low_temperature: 60.0, description: "sunny" },
    { date: (Time.current + 1.day).strftime('%Y-%m-%d'), high_temperature: 78.0, low_temperature: 58.0, description: "cloudy" }
  ].to_json
end
