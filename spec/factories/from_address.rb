FactoryBot.define do
  factory :from_address do
    service_id { SecureRandom.uuid }
    email { 'bob@gmail.com' }
  end
end
