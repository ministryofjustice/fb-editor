FactoryBot.define do
  factory :publish_service do
    service_id { SecureRandom.uuid }
    version_id { SecureRandom.uuid }
    user

    trait :queued do
      status { 'queued' }
    end

    trait :completed do
      status { 'completed' }
    end

    trait :unpublishing do
      status { 'unpublishing' }
    end

    trait :unpublished do
      status { 'unpublished' }
    end

    trait :dev do
      deployment_environment { 'dev' }
    end

    trait :production do
      deployment_environment { 'production' }
    end
  end
end
