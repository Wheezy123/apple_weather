FactoryBot.define do
  factory :address do
    street_address { '123 Main St' }
    city { 'Austin' }
    state { 'TX' }
    zip_code { '78701' }
  end
end
