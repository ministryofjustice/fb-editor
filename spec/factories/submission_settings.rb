FactoryBot.define do
  factory :submission_setting do
    service_id { SecureRandom.uuid }

    trait :dev do
      deployment_environment { 'dev' }
    end

    trait :production do
      deployment_environment { 'production' }
    end

    trait :send_email do
      send_email { true }
    end

    trait :do_not_send_email do
      send_email { false }
    end

    trait :service_csv_output do
      service_csv_output { true }
    end

    trait :send_confirmation_email do
      send_confirmation_email { true }
    end

    trait :payment_link do
      payment_link { true }
    end

    trait :send_to_graph_api do
      send_to_graph_api { true }
    end

    trait :do_not_send_to_graph_api do
      send_to_graph_api { false }
    end
  end
end
