FactoryBot.define do
  factory :weather_forecast do
    zip_code { "MyString" }
    current_temperature { "9.99" }
    high_temperature { "9.99" }
    low_temperature { "9.99" }
    description { "MyString" }
    cached_at { "2025-07-26 10:26:58" }
  end
end
