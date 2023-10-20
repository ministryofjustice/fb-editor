module Admin
  class TestServicesController < Admin::ApplicationController
    before_action :authenticate_test_user!
    before_action :deny_live_environment!
    skip_before_action :authenticate_admin

    ACCEPTANCE_TEST_FIXTURE = 'acceptance_test_fixture'.freeze

    def create
      service_creation = ServiceCreation.new(
        service_name: test_service_name,
        current_user:
      )

      if service_creation.create
        test_service_version = AdminMetadataVersion.new(
          service: OpenStruct.new(service_id: service_creation.service_id),
          metadata: fixture_metadata.merge(test_service_attributes(service_creation))
        ).create_version

        if test_service_version
          ServiceConfiguration.find_or_initialize_by(
            service_id: service_creation.service_id,
            deployment_environment: 'production',
            name: 'APPROVED_TO_GO_LIVE',
            value: test_service_name
          ).save! unless test_service_name =~ /no_approval/

          redirect_to edit_service_path(service_creation.service_id)
        else
          render json: {
            message: "Failed to create test service version -> #{test_service_name}"
          }, status: :bad_request
        end
      else
        render json: {
          message: "Failed to create test service -> #{test_service_name}"
        }, status: :bad_request
      end
    end

    def authenticate_test_user!
      unless current_user.email == 'fb-acceptance-tests@digital.justice.gov.uk'
        render json: { message: 'Unauthorised' }, status: :unauthorized
      end
    end

    def deny_live_environment!
      if ENV['PLATFORM_ENV'] == 'live'
        render json: { message: 'Unauthorised' }, status: :unauthorized
      end
    end

    def fixture_metadata
      JSON.parse(
        File.read(
          Rails.root.join(
            'acceptance',
            'fixtures',
            "#{fixture_name}.json"
          )
        )
      )
    end

    def fixture_name
      return ACCEPTANCE_TEST_FIXTURE if params[:fixture].blank?

      params[:fixture]
    end

    def test_service_attributes(service_creation)
      {
        'service_name' => service_creation.service_name,
        'service_id' => service_creation.service_id,
        'created_by' => current_user.id
      }
    end

    def test_service_name
      @test_service_name ||= params.require(:test_service_name)
    end
  end
end
