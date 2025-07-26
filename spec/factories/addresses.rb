FactoryBot.define do
  factory :address do
    street_address { "MyString" }
    city { "MyString" }
    state { "MyString" }
    zip_code { "MyString" }
    latitude { "9.99" }
    longitude { "9.99" }
    geocoded_at { "2025-07-26 10:23:51" }
  end
end
