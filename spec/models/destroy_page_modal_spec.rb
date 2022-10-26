RSpec.describe DestroyPageModal do
  subject(:destroy_page_modal) do
    described_class.new(
      service: service,
      page: page
    )
  end
  let(:service_metadata) { metadata_fixture(:branching_2) }

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
      context 'when there is a confirmation email that depends on the page' do
        let(:service_configuration) do
          create(
            :service_configuration,
            name: 'CONFIRMATION_EMAIL_COMPONENT_ID',
            value: 'email-address_email_1',
            deployment_environment: 'dev'
          )
        end
        let(:service_metadata) { metadata_fixture(:version) }
        let(:page) { service.find_page_by_url('email-address') }

        before do
          allow(destroy_page_modal).to receive(:confirmation_email_component_id).and_return(service_configuration)
        end

        it 'returns delete_page_used_for_confirmation_email' do
          expect(partial).to eq('api/pages/delete_page_used_for_confirmation_email_modal')
        end
      end

      context 'when deleting a page without any consequences' do
        let(:page) { service.find_page_by_url('page-h') }

        it 'returns the default delete partial' do
          expect(partial).to eq('api/pages/delete_modal')
        end
      end

      context 'when confirmation email is not set' do
        let(:page) { service.find_page_by_url('page-h') }

        before do
          allow(destroy_page_modal).to receive(:confirmation_email_component_id).and_return(nil)
        end

        it 'returns the default delete partial' do
          expect(partial).to eq('api/pages/delete_modal')
        end
      end
    end
  end
end
