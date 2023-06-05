RSpec.describe TestableEditorRemover do
  subject(:testable_editor_remover) { described_class.new }

  context 'removing testable editors' do
    let(:remote_branches) do
      "origin/HEAD -> origin/main\n  origin/acceptance-test/delete-component-multi-question\n  origin/main\n  origin/test-create-form\n  origin/testable-editor-to-keep"
    end
    let(:kubernetes_deployments) do
      "NAME                                                              READY   UP-TO-DATE   AVAILABLE   AGE\ntestable-editor-to-keep-web-test                                2/2     2            2           134d\nfb-metadata-api-test                                              2/2     2            2           245d\ntestable-editor-to-remove-web-test       2/2     2            2           2d3h"
    end
    let(:expected_targets) do
      [
        { config: 'configmap', name: 'testable-editor-to-remove-config-map' },
        { config: 'deployment', name: 'testable-editor-to-remove-web-test' },
        { config: 'hpa', name: 'testable-editor-to-remove-web-test' },
        { config: 'ingress', name: 'testable-editor-to-remove-ing-test' },
        { config: 'service', name: 'testable-editor-to-remove-svc-test' },
        { config: 'servicemonitor', name: 'testable-editor-to-remove-service-monitor-test' }
      ]
    end
    let(:expected_params) do
      {
        namespace: 'formbuilder-saas-test',
        targets: expected_targets
      }
    end
    let(:webhook) { 'https://www.example.com' }
    let(:removal_service) { double(call: true, status: []) }

    before do
      allow(ENV).to receive(:[])
      allow(ENV).to receive(:[]).with('SLACK_WEBHOOK').and_return(webhook)
      allow(testable_editor_remover).to receive(
        :remote_branches
      ).and_return(remote_branches)
      allow(testable_editor_remover).to receive(
        :kubernetes_deployments
      ).and_return(kubernetes_deployments)
      stub_request(:post, webhook)
        .with(
          body: '{"text":"","username":"MOJ Forms Editor","icon_emoji":":rockon:"}',
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent' => 'Ruby'
          }
        ).to_return(status: 200, body: '', headers: {})
    end

    it 'should call the removal service with the expected parameters' do
      expect(K8sConfigRemovalService).to receive(
        :new
      ).with(expected_params).and_return(removal_service)
      testable_editor_remover.call
    end
  end
end
