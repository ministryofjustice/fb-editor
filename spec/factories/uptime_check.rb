FactoryBot.define do
  factory :uptime_check do
    service_id { SecureRandom.uuid }
    check_id { SecureRandom.uuid }
  end
end
