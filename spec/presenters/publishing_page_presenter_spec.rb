RSpec.describe PublishingPagePresenter do
  subject(:publishing_page_presenter) do
    described_class.new(
      service:,
      deployment_environment:,
      service_autocomplete_items:,
      grid:
    )
  end
  let(:deployment_environment) { 'dev' }
  let(:service_autocomplete_items) { double(messages: []) }
  let(:grid) { MetadataPresenter::Grid.new(service) }

  describe '#publish_creation' do
    it 'returns an instance of a publish creation' do
      expect(subject.publish_creation).to be_a PublishServiceCreation
    end
  end

  describe '#autocomplete_warning' do
    it 'returns an instance of a publish creation' do
      expect(subject.autocomplete_warning).to be_a AutocompleteItemsPresenter
    end
  end

  describe '#service_output_warning' do
    it 'returns an instance of a service output warning presenter' do
      expect(subject.service_output_warning).to be_a ServiceOutputWarningPresenter
    end
  end

  describe '#submission_warnings' do
    it 'returns an instance of submission warnings' do
      expect(subject.submission_warnings).to be_a SubmissionWarningsPresenter
    end

    context 'submission warning presenters in production' do
      let(:deployment_environment) { 'production' }

      let(:submission_pages_presenter) { double }
      let(:autocomplete_warning) { double }

      before do
        allow(subject).to receive(:submission_pages_presenter).and_return(submission_pages_presenter)
        allow(subject).to receive(:autocomplete_warning).and_return(autocomplete_warning)
        allow(subject).to receive(:service_output_warning).and_return(service_output_warning)
      end

      context 'service output warning present' do
        let(:service_output_warning) { double(blank?: false) }
        let(:presenters) do
          [
            submission_pages_presenter,
            autocomplete_warning
          ]
        end
        it 'returns the expected presenters' do
          expect(subject.submission_warnings.presenters).to match_array(presenters)
        end
      end

      context 'service output warning not present' do
        let(:service_output_warning) { double(blank?: true) }
        let(:presenters) do
          [
            submission_pages_presenter,
            autocomplete_warning
          ]
        end

        it 'returns the expected presenters' do
          expect(subject.submission_warnings.presenters).to match_array(presenters)
        end
      end
    end

    context 'submission warning presenters in dev' do
      let(:presenters) { [submission_pages_presenter] }
      let(:submission_pages_presenter) { double }

      before do
        allow(subject).to receive(:submission_pages_presenter).and_return(submission_pages_presenter)
      end

      it 'returns the expected presenters' do
        expect(subject.submission_warnings.presenters).to match_array(presenters)
      end
    end
  end

  describe '#publish_button_disabled?' do
    context 'service output is disabled' do
      before do
        allow_any_instance_of(PublishServiceCreation).to receive(:no_service_output?).and_return(true)
      end
      it 'returns falsey' do
        expect(subject.publish_button_disabled?).to be_falsey
      end
    end

    context 'deployment environment is dev' do
      context 'when the service output is enabled' do
        let(:deployment_environment) { 'dev' }

        before do
          allow_any_instance_of(PublishServiceCreation).to receive(:no_service_output?).and_return(false)
        end

        context 'when there are submission warnings' do
          before do
            allow_any_instance_of(SubmissionWarningsPresenter).to receive(:messages).and_return(['Some messages'])
          end

          it 'returns falsey' do
            expect(subject.publish_button_disabled?).to be_falsey
          end
        end

        context 'when there are autocomplete warnings' do
          before do
            allow_any_instance_of(AutocompleteItemsPresenter).to receive(:messages).and_return(['Some messages'])
            allow_any_instance_of(AutocompleteItemsPresenter).to receive(:component_uuids_without_items).and_return(['Some components uuids'])
          end

          it 'returns falsey' do
            expect(subject.publish_button_disabled?).to be_falsey
          end
        end

        context 'when there are no submission or autocomplete warnings' do
          before do
            allow_any_instance_of(SubmissionWarningsPresenter).to receive(:messages).and_return([])
            allow_any_instance_of(AutocompleteItemsPresenter).to receive(:messages).and_return([])
          end

          it 'returns falsey' do
            expect(subject.publish_button_disabled?).to be_falsey
          end
        end
      end
    end

    context 'deployment environment is live' do
      context 'when the service output is enabled' do
        let(:deployment_environment) { 'production' }

        before do
          allow_any_instance_of(PublishServiceCreation).to receive(:no_service_output?).and_return(false)
        end

        context 'when there are submission warnings' do
          before do
            allow_any_instance_of(SubmissionWarningsPresenter).to receive(:messages).and_return(['Some messages'])
          end

          it 'returns truthy' do
            expect(subject.publish_button_disabled?).to be_truthy
          end
        end

        context 'when there are autocomplete warnings' do
          before do
            allow_any_instance_of(AutocompleteItemsPresenter).to receive(:messages).and_return(['Some messages'])
            allow_any_instance_of(AutocompleteItemsPresenter).to receive(:component_uuids_without_items).and_return(['Some components uuids'])
          end

          it 'returns truthy' do
            expect(subject.publish_button_disabled?).to be_truthy
          end
        end

        context 'when there are no submission or autocomplete warnings' do
          before do
            allow_any_instance_of(SubmissionWarningsPresenter).to receive(:messages).and_return([])
            allow_any_instance_of(AutocompleteItemsPresenter).to receive(:messages).and_return([])
          end

          it 'returns falsey' do
            expect(subject.publish_button_disabled?).to be_falsey
          end
        end
      end
    end
  end
end
