RSpec.describe FromAddressSync do
  subject(:from_address_sync) { described_class.new }
  let(:identities) do
    [
      double(identity_name: enabled_email, identity_type: 'EMAIL_ADDRESS', sending_enabled: true),
      double(identity_name: disabled_email, identity_type: 'EMAIL_ADDRESS', sending_enabled: false)
    ]
  end

  let(:enabled_email) { 'paddington.bear@justice.gov.uk' }
  let(:disabled_email) { 'yogi.bear@justice.gov.uk' }
  let(:service_id) { SecureRandom.uuid }
  let(:from_address) { FromAddress.find_or_initialize_by(service_id:) }

  describe '#call' do
    context 'when records are pending' do
      before do
        allow(from_address_sync).to receive(
          :email_identities
        ).and_return(identities)
      end

      context 'when status is enable in AWS' do
        before do
          create(:from_address, :pending, service_id:, email: enabled_email)
        end
        it 'updates record to verified' do
          from_address_sync.call
          expect(from_address.reload.status).to eq('verified')
        end
      end

      context 'when status is disable in AWS' do
        before do
          create(:from_address, :pending, service_id:, email: disabled_email)
        end

        it 'does not update record' do
          from_address_sync.call
          expect(from_address.reload.status).to eq('pending')
        end
      end
    end
  end
end
