RSpec.describe K8sConfigRemovalService do
  subject(:removal_service) do
    described_class.new(namespace:, targets:)
  end

  context 'removing target kubernetes configurations' do
    let(:namespace) { 'it is full of stars' }
    let(:targets) do
      [
        { config: 'config1', name: 'something-to-remove' },
        { config: 'config2', name: 'something-else-to-remove' },
        { config: 'config3', name: 'this-too' }
      ]
    end

    context 'successfully removing configurations' do
      let(:status_messages) do
        [
          'Successfully deleted config1 for something-to-remove',
          'Successfully deleted config2 for something-else-to-remove',
          'Successfully deleted config3 for this-too'
        ]
      end

      before do
        allow(Publisher::Utils::Shell).to receive(:output_of).and_return(true)
      end

      it 'creates the correct success status messages' do
        removal_service.call
        expect(removal_service.status).to eq(status_messages)
      end
    end

    context 'failed to remove configurations' do
      let(:status_messages) do
        [
          'Failed to delete config1 for something-to-remove',
          'Failed to delete config2 for something-else-to-remove',
          'Failed to delete config3 for this-too'
        ]
      end

      before do
        allow(Publisher::Utils::Shell).to receive(
          :output_of
        ).and_raise(Publisher::Utils::Shell::CmdFailedError)
      end

      it 'creates the correct failure status messages' do
        removal_service.call
        expect(removal_service.status).to eq(status_messages)
      end
    end

    context 'kubectl commands' do
      let(:config) { 'some-config' }
      let(:name) { 'some-name' }
      let(:targets) { [{ config:, name: }] }

      before do
        allow(Publisher::Utils::Shell).to receive(:capture_with_stdin).and_return('success')
      end

      it 'runs the correct kubectil commands' do
        expect(Publisher::Utils::Shell).to receive(
          :output_of
        ).with('$(which kubectl)', "delete #{config} #{name} -n #{namespace}").once
        removal_service.call
      end
    end
  end
end
