RSpec.describe ServiceCreation do
  subject(:service_creation) do
    described_class.new(attributes)
  end
  let(:current_user) { double(id: '1') }

  describe '#create' do
    context 'when is invalid' do
      context 'when name is blank' do
        let(:attributes) { { service_name: '' } }

        it 'returns false' do
          expect(service_creation.create).to be_falsey
        end
      end

      context 'when name is too short' do
        let(:attributes) { { service_name: 'ET' } }

        it 'returns false' do
          expect(service_creation.create).to be_falsey
        end
      end

      context 'when name is too long' do
        let(:attributes) { { service_name: 'E' * 256 } }

        it 'returns false' do
          expect(service_creation.create).to be_falsey
        end
      end

      context 'when name is in the legacy' do
        let(:service_name) { 'So you want to become an avenger' }
        let(:attributes) { { service_name: } }
        let!(:legacy_service_name) do
          create(:legacy_service_name, name: service_name)
        end

        it 'returns false' do
          expect(service_creation.create).to be_falsey
        end
      end

      context 'when user inputs name with trailing whitespace' do
        let(:current_user) { double(id: '1') }
        let(:attributes) { { service_name: '  Form Name  ', current_user: } }

        it 'strips whitespace' do
          expect(NewServiceGenerator).to receive(:new)
            .with(service_name: 'Form Name', current_user:)
            .and_return(double(to_metadata: 'metadata'))
          subject.metadata
        end
      end

      context 'when API returns errors' do
        let(:attributes) do
          { service_name: 'Moff Gideon', current_user: double(id: '1') }
        end
        let(:errors) do
          double(errors: ['Name is already been taken'], errors?: true)
        end

        before do
          expect(
            MetadataApiClient::Service
          ).to receive(:create).and_return(errors)
        end

        it 'returns false' do
          expect(service_creation.create).to be_falsey
        end

        it 'assigns error messages' do
          service_creation.create
          expect(
            service_creation.errors.full_messages.first
          ).to include('is already used by another form. Please modify it.')
        end
      end
    end

    context 'when is valid' do
      let(:attributes) do
        { service_name: "Secure Children's Home", current_user: double(id: '1') }
      end
      let(:service) do
        double(id: '05e12a93-3978-4624-a875-e59893f2c262', errors?: false)
      end

      before do
        expect(
          MetadataApiClient::Service
        ).to receive(:create).and_return(service)

        expect_any_instance_of(DefaultConfiguration).to receive(:create)
      end

      it 'returns true' do
        expect(service_creation.create).to be_truthy
      end

      it 'assigns service id' do
        service_creation.create
        expect(
          service_creation.service_id
        ).to eq('05e12a93-3978-4624-a875-e59893f2c262')
      end

      context 'when name has special characters' do
        let(:attributes) do
          { service_name: '$p£ci@l.(har%', current_user: double(id: '1') }
        end

        it 'returns true' do
          expect(service_creation.create).to be_truthy
        end
      end

      context 'when service name begins with a number' do
        let(:attributes) do
          { service_name: '001 Service', current_user: double(id: '1') }
        end

        it 'returns true' do
          expect(service_creation.create).to be_truthy
        end
      end
    end

    context 'when service name has an apostrophe' do
      let(:attributes) do
        { service_name: 'Secure Children’s Home', current_user: double(id: '1') }
      end
      let(:service) do
        double(id: '05e12a93-3978-4624-a875-e59893f2c262', errors?: false)
      end

      before do
        expect(
          MetadataApiClient::Service
        ).to receive(:create).and_return(service)

        expect_any_instance_of(DefaultConfiguration).to receive(:create)
      end

      it 'returns true' do
        expect(service_creation.create).to be_truthy
      end
    end

    context 'when service name has parenthesis' do
      let(:attributes) do
        { service_name: 'Public Trustee (NL1)', current_user: double(id: '1') }
      end
      let(:service) do
        double(id: '05e12a93-3978-4624-a875-e59893f2c262', errors?: false)
      end

      before do
        expect(
          MetadataApiClient::Service
        ).to receive(:create).and_return(service)

        expect_any_instance_of(DefaultConfiguration).to receive(:create)
      end

      it 'returns true' do
        expect(service_creation.create).to be_truthy
      end
    end
  end

  describe '#metadata' do
    let(:attributes) do
      { service_name: 'Moff Gideon', current_user: double(id: '1234') }
    end

    it 'generates the metadata for the API' do
      expect(service_creation.metadata[:metadata]).to include(
        {
          'service_name' => 'Moff Gideon',
          'created_by' => '1234'
        }
      )
    end
  end
end
