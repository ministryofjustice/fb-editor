RSpec.describe MicrosoftListSettingsValidator do
  let(:record) { MsListSetting.new({ ms_site_id: answer, deployment_environment: 'dev', send_to_ms_list: '1', service: }) }

  describe '#validate' do
    context 'when not present' do
      %w[nil].each do |invalid_answer|
        let(:answer) { invalid_answer }

        it 'returns invalid' do
          expect(subject.validate(record)).to be(false)
        end
      end
    end

    context 'when not a uuid' do
      %w[nil hello 123-123-123-123].each do |invalid_answer|
        let(:answer) { invalid_answer }

        it 'returns invalid' do
          expect(subject.validate(record)).to be(false)
        end
      end
    end

    context 'when conforming uuid format' do
      let(:answer) { SecureRandom.uuid }

      it 'returns valid' do
        expect(subject.validate(record)).to be(true)
      end
    end
  end
end
