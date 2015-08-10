FactoryGirl.define do
  factory :app do
    id { Faker::Number.number(7) }
    name { Faker::App.name }
    description { Faker::Lorem.paragraph }
    icon_url { Faker::Internet.url }
    publisher_id { Faker::Number.number(7) }
    publisher_name { Faker::App.author }
    price { Faker::Commerce.price }
    version { Faker::App.version }
    rating { Faker::Number.number(2) }
  end
end