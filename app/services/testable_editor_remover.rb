class TestableEditorRemover
  WEB = '-web-test'.freeze
  CONFIGURATIONS = [
    { type: 'configmap', append: '-config-map' },
    { type: 'deployment', append: WEB },
    { type: 'hpa', append: WEB },
    { type: 'ingress', append: '-ing-test' },
    { type: 'service', append: '-svc-test' },
    { type: 'servicemonitor', append: '-service-monitor-test' }
  ].freeze
  NAMESPACE = 'formbuilder-saas-test'.freeze
  ORIGIN = 'origin/'.freeze
  TESTABLE = 'testable-'.freeze

  def call
    testable_editors_to_remove.each do |testable_editor|
      k8s_config_removal_service(testable_editor).tap do |removal_service|
        removal_service.call
        if webhook
          NotificationService.notify(
            removal_service.status.join("\n"),
            webhook: ENV['SLACK_WEBHOOK']
          )
        end
      end
    end
  end

  private

  def testable_editors_to_remove
    unique_testable_deployments - testable_editor_branches
  end

  def testable_editor_branches
    branches = remote_branches.split(' ').map do |branch|
      branch.gsub(ORIGIN, '') if branch.include?(TESTABLE)
    end
    branches.compact
  end

  def remote_branches
    run('$(which git) branch -r')
  end

  def unique_testable_deployments
    deployments = kubernetes_deployments.split("\n").map do |deployment|
      if deployment.include?(TESTABLE)
        deployment.split(' ')[0].gsub(/#{WEB}/, '')
      end
    end
    deployments.compact.uniq
  end

  def kubernetes_deployments
    run("$(which kubectl) get deployments -n #{NAMESPACE}")
  end

  def run(cmd)
    Publisher::Utils::Shell.output_of(cmd)
  rescue Publisher::Utils::Shell::CmdFailedError => e
    Sentry.capture_exception(e)
  end

  def k8s_config_removal_service(testable_editor)
    K8sConfigRemovalService.new(namespace: NAMESPACE, targets: targets(testable_editor))
  end

  def targets(testable_editor)
    CONFIGURATIONS.map do |configuration|
      {
        config: configuration[:type],
        name: "#{testable_editor}#{configuration[:append]}"
      }
    end
  end

  def webhook
    # This is only run during deployment. SLACK_WEBHOOK exists in the CircleCI deployment job
    # SLACK_PUBLISH_WEBHOOK is used by the Editor itself when running in Test or Live
    @webhook ||= ENV['SLACK_WEBHOOK']
  end
end
