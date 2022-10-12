RSpec.describe Settings::FromAddressController do
  describe '#from_address_params' do
    let(:default_email) { I18n.t('default_values.service_email_from') }

    let(:params) do
      {
        authenticity_token: 'some-token',
        from_address: {
          email: default_email
        }
      }
    end

    let(:expected_params) { { email: 'hello@email.com' } }

    before do
      allow(controller).to receive(:params).and_return(
        ActionController::Parameters.new(params)
      )
    end

    context 'when a user submit a valid email address' do
      it 'sets emails param' do
        expect(controller.from_address_params['email']).to eq(params[:from_address][:email])
      end
    end

    context 'when the email submitted is empty' do
      let(:default_email) { '' }

      it 'fails to submit an empty email' do
        expect(controller.from_address_params['email']).to eq(params[:from_address][:email])
      end
    end
  end
end
