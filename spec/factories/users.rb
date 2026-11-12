FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "legolas-#{n}@middle-earth.co.uk" }
    name { 'Legolas' }
  end
end
