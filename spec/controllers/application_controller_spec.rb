RSpec.describe ApplicationController do
  describe '#editable?' do
    before do
      allow(
        controller.request
      ).to receive(:script_name).and_return(script_name)
    end

    context 'when editing a page' do
      let(:script_name) { 'services/1/pages/2/edit' }

      it 'returns true' do
        expect(controller).to be_editable
      end
    end

    context 'when previewing a page' do
      let(:script_name) { 'services/1/preview' }

      it 'returns true' do
        expect(controller).to_not be_editable
      end
    end
  end

  describe '#save_user_data' do
    before do
      allow(controller).to receive(:params).and_return(params)
      allow(controller).to receive(:answer_params).and_return(answer_params)
      controller.save_user_data
    end

    context 'when saving uploaded file' do
      let(:params) do
        {
          answers: {
            'computer' => Rack::Test::UploadedFile.new(
              Rails.root.join('spec', 'fixtures', 'computer_says_no.gif'),
              'image/gif'
            )
          },
          id: '123456'
        }
      end
      let(:answer_params) do
        {
          'computer' => {
            'original_filename' => 'computer_says_no.gif',
            'content_type' => 'application/image',
            'tempfile' => 'path/to/file/computer_says_no.gif'
          }
        }
      end

      it 'saves it with the service id' do
        expect(controller.session.to_h).to eq(
          { '123456' => { 'user_data' => answer_params } }
        )
      end
    end

    context 'when saving user data to the session' do
      let(:answer_params) { { 'frodo' => 'samwise' } }
      let(:params) do
        {
          answers: answer_params,
          id: '123456'
        }
      end

      it 'saves it with the service id' do
        expect(controller.session.to_h).to eq(
          {
            '123456' => {
              'user_data' => {
                'frodo' => 'samwise'
              }
            }
          }
        )
      end

      it 'retrieves user data using the service id' do
        expect(controller.load_user_data.to_h).to eq(
          { 'frodo' => 'samwise' }
        )
      end
    end

    context 'with no service id in the params' do
      let(:answer_params) { {} }
      let(:params) { {} }

      it 'saves nothing' do
        expect(controller.load_user_data.to_h).to eq({})
      end
    end
  end

  describe '#user_name' do
    context 'with a current user' do
      context 'two names' do
        before do
          allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(
            double(name: 'Peggy Carter')
          )
        end

        it 'should show the correctly formatted user name' do
          expect(controller.user_name).to eq('P. Carter')
        end
      end

      context 'more than two names' do
        before do
          allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(
            double(name: 'Sponge Bob Square Pants')
          )
        end

        it 'should show the correctly formatted user name' do
          expect(controller.user_name).to eq('S. Pants')
        end
      end
    end
  end

  describe '#autocomplete_items' do
    before do
      allow(controller).to receive(:service).and_return(service)
      allow(MetadataApiClient::Items).to receive(:find).and_return(api_response)
    end

    context 'when there are items on an autocomplete component' do
      let(:page_with_items) { service.find_page_by_url('/countries') }
      let(:component_id) { page_with_items['components'].first['_uuid'] }
      let(:component_items) { { component_id => [{ 'text': 'abc', 'value': '123' }] } }
      let(:api_response) do
        MetadataApiClient::Items.new(
          { 'items' => component_items }
        )
      end

      it 'returns the autocomplete items on the page' do
        expect(controller.autocomplete_items(page_with_items.components)).to eq(component_items)
      end
    end

    context 'when there are no items on an autocomplete component' do
      let(:component_id) { '123456' }
      let(:page_without_items) do
        page = service.find_page_by_url('/countries')
        page.components.first.uuid.replace(component_id)
        page
      end
      let(:api_response) { MetadataApiClient::ErrorMessages.new(['the component has no autocomplete items']) }

      it 'logs the error message' do
        expect(Rails.logger).to receive(:info).with(['the component has no autocomplete items'])
        expect(controller.autocomplete_items(page_without_items.components)).to eq({})
      end
    end
  end

  describe '#reference_number_enabled?' do
    before do
      allow(controller).to receive(:service).and_return(service)
      allow(ServiceConfiguration).to receive(:find_by).and_return(service_configuration)
    end

    context 'when REFERENCE_NUMBER is enabled' do
      let!(:service_configuration) do
        create(
          :service_configuration,
          :dev,
          :reference_number,
          service_id: service.service_id
        )
      end

      it 'returns true' do
        expect(controller.reference_number_enabled?).to be_truthy
      end
    end

    context 'when REFERENCE_NUMBER is disabled' do
      let!(:service_configuration) { nil }

      it 'returns false' do
        expect(controller.reference_number_enabled?).to be_falsey
      end
    end
  end

  describe '#payment_link_enabled?' do
    before do
      allow(controller).to receive(:service).and_return(service)
      allow(SubmissionSetting).to receive(:find_by).and_return(submission_setting)
    end

    context 'when payment link is enabled' do
      let!(:submission_setting) do
        create(
          :submission_setting,
          :dev,
          :payment_link,
          service_id: service.service_id
        )
      end

      it 'returns true' do
        expect(controller.payment_link_enabled?).to be_truthy
      end
    end

    context 'when payment link is disabled and payment_link_url is present' do
      let!(:submission_setting) { nil }
      let!(:service_configuration) do
        create(
          :service_configuration,
          :dev,
          :payment_link_url,
          service_id: service.service_id
        )
      end

      it 'returns false' do
        expect(controller.reference_number_enabled?).to be_falsey
      end
    end
  end

  describe '#save_and_return_enabled?' do
    before do
      allow(controller).to receive(:service).and_return(service)
      allow(ServiceConfiguration).to receive(:find_by).and_return(service_configuration)
    end

    context 'when SAVE_AND_RETURN is enabled' do
      let!(:service_configuration) do
        create(
          :service_configuration,
          :dev,
          :save_and_return,
          service_id: service.service_id
        )
      end

      it 'returns true' do
        expect(controller.save_and_return_enabled?).to be_truthy
      end
    end

    context 'when SAVE_AND_RETURN is disabled' do
      let!(:service_configuration) { nil }

      it 'returns false' do
        expect(controller.save_and_return_enabled?).to be_falsey
      end
    end
  end

  describe '#editor_preview?' do
    before do
      allow(
        controller.request
      ).to receive(:script_name).and_return(script_name)
    end

    context 'when editing a page' do
      let(:script_name) { 'services/1/pages/2/edit' }

      it 'returns false' do
        expect(controller.editor_preview?).to be_falsey
      end
    end

    context 'when previewing a page' do
      let(:script_name) { 'services/1/preview' }

      it 'returns true' do
        expect(controller.editor_preview?).to be_truthy
      end
    end
  end

  describe '#service_slug' do
    before do
      allow(controller).to receive(:service).and_return(service)
    end

    context 'when SERVICE_SLUG exists' do
      before do
        allow(controller).to receive(:service_slug_config).and_return('service-slug')
      end

      it 'returns service slug' do
        expect(controller.service_slug).to eq('service-slug')
      end
    end

    context 'when SERVICE_SLUG does not exists' do
      it 'returns service slug' do
        expect(controller.service_slug).to eq('version-fixture')
      end
    end
  end

  describe '#service_slug_config' do
    before do
      allow(controller).to receive(:service).and_return(service)
      allow(ServiceConfiguration).to receive(:find_by).and_return(service_configuration)
    end

    context 'when SERVICE_SLUG exists' do
      let!(:service_configuration) do
        create(
          :service_configuration,
          :dev,
          :service_slug,
          service_id: service.service_id
        )
      end

      it 'returns service slug' do
        expect(controller.service_slug_config).to eq('eat-slugs-malfoy')
      end
    end

    context 'when SERVICE_SLUG does not exist' do
      let!(:service_configuration) { nil }

      it 'returns nil' do
        expect(controller.service_slug_config).to be_nil
      end
    end
  end

  describe '#confirmation_email' do
    before do
      allow(controller).to receive(:service).and_return(service)
      allow(ServiceConfiguration).to receive(:find_by).and_return(service_configuration)
    end

    context 'when CONFIRMATION_EMAIL_COMPONENT_ID is present' do
      let!(:service_configuration) do
        create(
          :service_configuration,
          :dev,
          :confirmation_email_component_id,
          service_id: service.service_id
        )
      end

      it 'confirmation_email_enabled? returns true' do
        expect(controller.confirmation_email_enabled?).to be_truthy
      end
    end

    context 'when CONFIRMATION_EMAIL_COMPONENT_ID is not present' do
      let!(:service_configuration) { nil }

      it 'confirmation_email_enabled? returns false' do
        expect(controller.confirmation_email_enabled?).to be_falsey
      end

      it 'confirmation_email doesn\'t return anything' do
        expect(controller.confirmation_email).to be_nil
      end
    end
  end
end
