RSpec.describe FromAddressPresenter do
  subject(:from_address_presenter) do
    described_class.new(
      from_address: from_address,
      messages: messages,
      service_id: service_id
    )
  end
  let(:service_id) { SecureRandom.uuid }
  let(:from_address) { FromAddress.find_by(service_id: service_id) }
  let(:link) do
    "<a class=\"govuk-link\" href=\"/services/#{service_id}/settings/submission/from_address\">‘from’ address</a>"
  end

  describe '#message' do
    context 'when from address page' do
      let(:messages) { I18n.t('warnings.from_address.settings') }

      context 'when from address is verified' do
        let(:expected_message) { I18n.t('warnings.from_address.settings.verified') }

        before do
          create(:from_address, :verified, service_id: service_id)
        end

        it 'returns the verified message' do
          expect(from_address_presenter.message).to eq(expected_message)
        end
      end

      context 'when from address is pending' do
        let(:expected_message) { I18n.t('warnings.from_address.settings.pending') }

        before do
          create(:from_address, :pending, service_id: service_id)
        end

        it 'returns the pending message' do
          expect(from_address_presenter.message).to eq(expected_message)
        end
      end

      context 'when from address is default' do
        let(:expected_message) { I18n.t('warnings.from_address.settings.default') }

        before do
          create(:from_address, :default, service_id: service_id)
        end

        it 'returns the default message' do
          expect(from_address_presenter.message).to eq(expected_message)
        end

        context 'when messages does not contain a specific key' do
          # some messages are not shown at all if the email address is verified
          let(:messages) { I18n.t('warnings.from_address.publishing') }

          it 'returns nil' do
            expect(from_address_presenter.message).to be_nil
          end
        end
      end
    end

    context 'when send by email page' do
      let(:messages) { I18n.t('warnings.from_address.send_by_email') }

      context 'when from address is verified' do
        let(:expected_message) { I18n.t('warnings.from_address.send_by_email.verified') }

        before do
          create(:from_address, :verified, service_id: service_id)
        end

        it 'returns the verified message' do
          expect(from_address_presenter.message).to eq(expected_message)
        end
      end

      context 'when from address is pending' do
        let(:expected_message) { I18n.t('warnings.from_address.send_by_email.pending') }

        before do
          create(:from_address, :pending, service_id: service_id)
        end

        it 'returns the pending message' do
          expect(from_address_presenter.message).to eq(expected_message)
        end
      end

      context 'when from address is default' do
        let(:expected_message) { I18n.t('warnings.from_address.send_by_email.default', href: link) }

        before do
          create(:from_address, :default, service_id: service_id)
          allow_any_instance_of(FromAddressPresenter).to receive(:link).and_return(link)
        end

        it 'returns the default message' do
          expect(from_address_presenter.message).to eq(expected_message)
        end
      end
    end

    context 'when publishing page' do
      let(:messages) { I18n.t('warnings.from_address.publishing.dev') }

      context 'when from address is pending' do
        let(:expected_message) { I18n.t('warnings.from_address.publishing.dev.pending', href: link) }

        before do
          create(:from_address, :pending, service_id: service_id)
          allow_any_instance_of(FromAddressPresenter).to receive(:link).and_return(link)
        end

        it 'returns the pending message' do
          expect(from_address_presenter.message).to eq(expected_message)
        end
      end

      context 'when from address is default' do
        let(:expected_message) { I18n.t('warnings.from_address.publishing.dev.default', href: link) }

        before do
          create(:from_address, :default, service_id: service_id)
        end

        it 'returns the default message' do
          expect(from_address_presenter.message).to eq(expected_message)
        end
      end
    end
  end
end
