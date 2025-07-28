FactoryBot.define do
  factory :weather_forecast do
    zip_code { "78701" }
    current_temperature { 75.0 }
    high_temperature { 85.0 }
    low_temperature { 65.0 }
    description { "partly cloudy" }
    cached_at { Time.current }

    trait :expired do
      cached_at { 1.hour.ago }
    end

    trait :fresh do
      cached_at { 10.minutes.ago }
    end
  end
end
