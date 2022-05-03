RSpec.describe 'Component validations spec', type: :request do
  describe 'GET /api/services/:service_id/component-validations/:component/:validator' do
    let(:service) { MetadataPresenter::Service.new(metadata) }

    allow_any_instance_of(
      Api::ComponentValidationsController
    ).to receive(:require_user!).and_return(true)

    allow_any_instance_of(
      Api::ComponentValidationsController
    ).to receive(:service).and_return(service)

    request
  end

  context 'something' do
    let(:request) do
      get "/api/services/some-service-id/component-validations/number/minimum"
    end
  end
end
