RSpec.describe ReferencePaymentSettings do
  subject(:reference_payment_settings) do
    described_class.new(
      params.merge(service_id: service.service_id)
    )
  end
  let(:params) { {} }
  let(:valid_url) { "#{I18n.t('activemodel.errors.models.reference_payment_settings.link_start_with')}123" }

  describe '#reference_number_checked?' do
    context 'when reference number is ticked' do
      let(:params) { { reference_number: '1' } }

      it 'returns true' do
        expect(reference_payment_settings.reference_number_checked?).to be_truthy
      end

      it 'does not retrieve the record in the database' do
        expect(ServiceConfiguration).to_not receive(:exists?)
      end
    end

    context 'when reference number is not ticked' do
      let(:params) { { reference_number: '0' } }

      it 'returns false' do
        expect(reference_payment_settings.reference_number_checked?).to be_falsey
      end

      it 'does not retrieve the record in the database' do
        expect(ServiceConfiguration).to_not receive(:exists?)
      end
    end

    context 'reference number is nil' do
      context 'when there is a DB record' do
        before do
          create(
            :service_configuration,
            :reference_number,
            service_id: service.service_id,
            deployment_environment: 'dev'
          )
          create(
            :service_configuration,
            :reference_number,
            service_id: service.service_id,
            deployment_environment: 'production'
          )
        end

        it 'returns true' do
          expect(reference_payment_settings.reference_number_checked?).to be_truthy
        end
      end
      context 'when there is no DB record' do
        it 'returns false' do
          expect(reference_payment_settings.reference_number_checked?).to be_falsey
        end
      end
    end
  end

  describe '#payment_link_url_enabled?' do
    context 'when there is a DB record' do
      before do
        create(
          :service_configuration,
          :payment_link_url,
          service_id: service.service_id,
          deployment_environment: 'dev'
        )
        create(
          :service_configuration,
          :payment_link_url,
          service_id: service.service_id,
          deployment_environment: 'production'
        )
      end

      context 'when payment link url is present' do
        context 'and checkbox is ticked' do
          let(:params) { { payment_link: '1', payment_link_url: 'www.payment_link.gov' } }

          it 'returns true' do
            expect(reference_payment_settings.payment_link_url_enabled?).to be_truthy
          end
        end
      end

      context 'when payment link url is not present' do
        it 'returns true' do
          expect(reference_payment_settings.payment_link_url_enabled?).to be_truthy
        end

        it 'returns the existing record from DB' do
          expect(ServiceConfiguration.exists?(service_id: service.service_id, name: 'PAYMENT_LINK')).to be_truthy
        end
      end
    end

    context 'when there is not DB record' do
      context 'when payment link url is present' do
        let(:params) { { payment_link_url: valid_url } }

        it 'returns true' do
          expect(reference_payment_settings.payment_link_url_enabled?).to be_truthy
        end
      end

      context 'when payment link url is not present' do
        context 'cannot get any record from the DB' do
          it 'returns false' do
            expect(reference_payment_settings.payment_link_url_enabled?).to be_falsey
          end
        end
      end
    end
  end

  describe '#payment_link_has_been_checked?' do
    context 'payment_link is blank' do
      context 'when there is a DB record' do
        before do
          create(
            :submission_setting,
            :payment_link,
            service_id: service.service_id,
            deployment_environment: 'dev'
          )
          create(
            :submission_setting,
            :payment_link,
            service_id: service.service_id,
            deployment_environment: 'production'
          )
        end

        it 'returns true' do
          expect(reference_payment_settings.payment_link_has_been_checked?).to be_truthy
        end
      end

      context 'when there is no DB record' do
        it 'returns false' do
          expect(reference_payment_settings.payment_link_has_been_checked?).to be_falsey
        end
      end
    end

    context 'payment link is ticked' do
      let(:params) { { payment_link: '1', payment_link_url: '' } }

      context 'when there is a record in DB' do
        before do
          create(
            :submission_setting,
            :payment_link,
            service_id: service.service_id,
            deployment_environment: 'dev'
          )
          create(
            :submission_setting,
            :payment_link,
            service_id: service.service_id,
            deployment_environment: 'production'
          )
        end

        it 'returns true' do
          expect(reference_payment_settings.payment_link_has_been_checked?).to be_truthy
        end
      end

      context 'when there is no DB record' do
        it 'returns true' do
          expect(reference_payment_settings.payment_link_has_been_checked?).to be_truthy
        end
      end
    end
  end

  describe '#saved_payment_link_url' do
    context 'there is a service configuration saved in DB' do
      before do
        create(
          :service_configuration,
          :payment_link_url,
          service_id: service.service_id,
          deployment_environment: 'dev'
        )
        create(
          :service_configuration,
          :payment_link_url,
          service_id: service.service_id,
          deployment_environment: 'production'
        )
      end
      context 'payment link url is nil' do
        it 'will call the DB' do
          expect(subject).to_not receive(:payment_link_url)
        end
      end

      context 'payment link url is filled in' do
        let(:params) { { payment_link: '1', payment_link_url: valid_url } }

        it 'will not access the DB' do
          expect(ServiceConfiguration).to_not receive(:exists?)
        end
      end

      context 'when payment link url has whitespace' do
        let(:params) do
          {
            payment_link: '1',
            payment_link_url: 'https://www.gov.uk/payments/123   '
          }
        end

        it 'will remove the white space and save to the DB' do
          expect(
            ServiceConfiguration.find_by(
              service_id: service.service_id,
              name: 'PAYMENT_LINK'
            ).decrypt_value
          ).to eq('https://www.gov.uk/payments/123')
        end
      end
    end
  end
end
