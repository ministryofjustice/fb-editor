FactoryBot.define do
  factory :from_address do
    service_id { SecureRandom.uuid }
    email { 'bob@justice.gov.uk' }

    trait :verified do
      status { 2 }
    end

    trait :pending do
      status { 1 }
    end

    trait :default do
      status { 0 }
    end
  end
end
