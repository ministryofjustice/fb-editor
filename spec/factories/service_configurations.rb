FactoryBot.define do
  factory :service_configuration do
    service_id { SecureRandom.uuid }

    trait :dev do
      deployment_environment { 'dev' }
    end

    trait :production do
      deployment_environment { 'production' }
    end

    trait :username do
      name { ServiceConfiguration::BASIC_AUTH_USER }
      value { 'eC13aW5n' }
    end

    trait :password do
      name { ServiceConfiguration::BASIC_AUTH_PASS }
      value { 'dGllLWZpZ2h0ZXIK' }
    end

    trait :service_email_subject do
      name { 'SERVICE_EMAIL_SUBJECT' }
      value { 'Aren’t you a little short for a Stormtrooper?' }
    end

    trait :service_email_output do
      name { 'SERVICE_EMAIL_OUTPUT' }
      value { 'wookies@grrrrr.uk' }
    end

    trait :service_email_body do
      name { 'SERVICE_EMAIL_BODY' }
      value { 'Why, you stuck-up, half-witted, scruffy-looking nerf herder' }
    end

    trait :service_email_pdf_heading do
      name { 'SERVICE_EMAIL_PDF_HEADING' }
      value { 'Star killer complaints' }
    end

    trait :service_email_pdf_subheading do
      name { 'SERVICE_EMAIL_PDF_SUBHEADING' }
      value { 'Star killer HR' }
    end

    trait :ua do
      name { 'UA' }
      value { 'UA-123456' }
    end

    trait :gtm do
      name { 'GTM' }
      value { 'GTM-123456' }
    end

    trait :ga4 do
      name { 'GA4' }
      value { 'G-123456' }
    end

    trait :service_csv_output do
      name { 'SERVICE_CSV_OUTPUT' }
      value { 'true' }
    end

    trait :service_email_from do
      name { 'SERVICE_EMAIL_FROM' }
      value { 'luke.piewalker@digital.justice.gov.uk' }
    end

    trait :confirmation_email_subject do
      name { 'CONFIRMATION_EMAIL_SUBJECT' }
      value { "You're gonna need a bigger boat" }
    end

    trait :confirmation_email_body do
      name { 'CONFIRMATION_EMAIL_BODY' }
      value { 'We could not talk or talk forever and still find things to not talk about' }
    end

    trait :confirmation_email_component_id do
      name { 'CONFIRMATION_EMAIL_COMPONENT_ID' }
      value { 'email_question_1' }
    end

    trait :encoded_public_key do
      name { 'ENCODED_PUBLIC_KEY' }
      value { 'i_am_encoded' }
    end

    trait :maintenance_mode do
      name { 'MAINTENANCE_MODE' }
      value { '1' }
    end

    trait :maintenance_page_heading do
      name { 'MAINTENANCE_PAGE_HEADING' }
      value { 'It is broken' }
    end

    trait :reference_number do
      name { 'REFERENCE_NUMBER' }
      value { '1' }
    end
  end
end
