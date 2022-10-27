RSpec.describe DestroyPageModal do
  subject(:destroy_page_modal) do
    described_class.new(
      service: service,
      page: page
    )
  end
  let(:service_metadata) { metadata_fixture(:branching_2) }
  let(:page) { service.find_page_by_url('page-h') }

  describe '#to_partial_path' do
    subject(:partial) { destroy_page_modal.to_partial_path }

    context 'branching' do
      # branch destinations
      context 'when after branch' do
        context 'when there is no branch sequentially after the page' do
          context 'when the destination has a default next' do
            let(:page) { service.find_page_by_url('page-c') }

            it 'returns deleting branch destination page partial' do
              expect(partial).to eq('api/pages/delete_branch_destination_page_modal')
            end
          end
        end

        context 'when the destination has no default next' do
          let(:service_metadata) { metadata_fixture(:branching_7) }
          let(:page) { service.find_page_by_url('page-g') }

          it 'returns deleting branch destination page partial' do
            expect(partial).to eq('api/pages/delete_branch_destination_page_no_default_next_modal')
          end
        end

        context 'when there is a branch sequentially after the page' do
          let(:page) { service.find_page_by_url('page-j') }

          it 'returns not supported stack branches partial' do
            expect(partial).to eq('api/pages/stack_branches_not_supported_modal')
          end
        end
      end

      # used for branch conditionals
      context 'when there is a branch that depends on the page' do
        let(:page) { service.find_page_by_url('page-b') }

        it 'returns delete page used for branching not supported' do
          expect(partial).to eq('api/pages/delete_page_used_for_branching_not_supported_modal')
        end
      end
    end

    context 'confirmation email' do
      let(:service_metadata) { metadata_fixture(:version) }
      let(:page) { service.find_page_by_url('email-address') }
      let(:default_delete_partial) { 'api/pages/delete_modal' }
      let(:service_configuration) do
        create(
          :service_configuration,
          name: 'CONFIRMATION_EMAIL_COMPONENT_ID',
          value: value,
          deployment_environment: environment
        ).decrypt_value
      end

      context 'when confirmation email setting is checked in dev' do
        let(:environment) { 'dev' }

        context 'and the component is used on the page' do
          let(:value) { 'email-address_email_1' }

          before do
            create(:submission_setting, :dev, :send_confirmation_email, service_id: service.service_id)
            allow(destroy_page_modal).to receive(:confirmation_email_component_ids).and_return([service_configuration])
          end

          it 'returns delete_page_used_for_confirmation_email' do
            expect(partial).to eq('api/pages/delete_page_used_for_confirmation_email_modal')
          end
        end

        context 'and the component is not used on the page' do
          let(:value) { 'email-address_not-used' }

          before do
            create(:submission_setting, :dev, :send_confirmation_email, service_id: service.service_id)
            allow(destroy_page_modal).to receive(:confirmation_email_component_ids).and_return([service_configuration])
          end

          it 'returns the default delete partial' do
            expect(partial).to eq(default_delete_partial)
          end
        end
      end

      context 'when confirmation email setting is checked in production' do
        context 'and the component is not used on the page' do
          let(:environment) { 'production' }
          let(:value) { 'email-address_not_used' }

          before do
            create(:submission_setting, :production, :send_confirmation_email, service_id: service.service_id)
            allow(destroy_page_modal).to receive(:confirmation_email_component_ids).and_return([service_configuration])
          end

          it 'returns the default delete partial' do
            expect(partial).to eq(default_delete_partial)
          end
        end
      end

      context 'when there is a CONFIRMATION_EMAIL_COMPONENT_ID in both env' do
        let(:service_configuration_production) do
          create(
            :service_configuration,
            name: 'CONFIRMATION_EMAIL_COMPONENT_ID',
            value: 'email-address_email_1',
            deployment_environment: 'production'
          ).decrypt_value
        end
        let(:environment) { 'dev' }
        let(:value) { 'email-address_email_1' }

        context 'and only confirmation email setting is checked in dev' do
          before do
            create(:submission_setting, :dev, :send_confirmation_email, service_id: service.service_id)
            create(:submission_setting, :dev, send_confirmation_email: nil, service_id: service.service_id)
            allow(destroy_page_modal).to receive(:confirmation_email_component_ids).and_return([service_configuration])
          end

          it 'returns delete_page_used_for_confirmation_email' do
            expect(partial).to eq('api/pages/delete_page_used_for_confirmation_email_modal')
          end
        end

        context 'and no confirmation email settings have been checked' do
          before do
            create(:submission_setting, :dev, send_confirmation_email: nil, service_id: service.service_id)
            create(:submission_setting, :production, send_confirmation_email: nil, service_id: service.service_id)
            allow(destroy_page_modal).to receive(:confirmation_email_component_ids).and_return([service_configuration, service_configuration_production])
          end

          it 'returns the default delete partial' do
            expect(partial).to eq(default_delete_partial)
          end
        end
      end

      context 'when deleting a page without any consequences' do
        it 'returns the default delete partial' do
          expect(partial).to eq(default_delete_partial)
        end
      end

      context 'when send_confirmation_email is not set' do
        before do
          create(:submission_setting, :dev, send_confirmation_email: nil, service_id: service.service_id)
          create(:submission_setting, :production, send_confirmation_email: nil, service_id: service.service_id)
        end

        it 'returns the default delete partial' do
          expect(partial).to eq(default_delete_partial)
        end
      end
    end
  end
end
