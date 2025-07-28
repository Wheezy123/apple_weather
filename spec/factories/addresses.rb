FactoryBot.define do
  factory :address do
    street_address { "123 Main St" }
    city { "Austin" }
    state { "TX" }
    zip_code { "78701" }
    latitude { nil }
    longitude { nil }
    geocoded_at { nil }
  end
end
