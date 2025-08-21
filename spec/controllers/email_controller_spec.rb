RSpec.describe Settings::EmailController do
  describe '#email_settings_params' do
    let(:params) do
      {
        authenticity_token: 'some-token',
        email_settings: {
          "send_by_email_#{deployment_environment}": '1',
          deployment_environment:,
          service_email_output: '',
          service_email_subject: 'Submission from Version Fixture',
          service_email_body: 'Please find attached a submission sent from "Version Fixture"',
          service_email_pdf_heading: 'Submission for Version Fixture',
          service_email_pdf_subheading: ''
        }
      }
    end
    let(:expected_params) do
      {
        'send_by_email' => '1',
        'deployment_environment' => deployment_environment,
        'service_email_output' => '',
        'service_email_subject' => 'Submission from Version Fixture',
        'service_email_body' => 'Please find attached a submission sent from "Version Fixture"',
        'service_email_pdf_heading' => 'Submission for Version Fixture',
        'service_email_pdf_subheading' => ''
      }
    end

    before do
      allow(controller).to receive(:params).and_return(
        ActionController::Parameters.new(params)
      )
    end

    %w[dev production].each do |environment|
      context "when #{environment} deployment environment" do
        let(:deployment_environment) { environment }

        it "sets send_by_email param and rejects send_by_email_#{environment} param" do
          expect(controller.email_settings_params.to_h).to eq(expected_params)
        end
      end
    end
  end
end
