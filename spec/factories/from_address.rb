FactoryBot.define do
  factory :from_address do
    service_id { SecureRandom.uuid }
    email { 'bob@justice.gov.uk' }
    status { :unverified }
  end
end
