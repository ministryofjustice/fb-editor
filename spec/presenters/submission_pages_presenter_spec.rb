RSpec.describe SubmissionPagesPresenter do
  let(:link) do
    "<a target=\"_blank\" class=\"govuk-link\" href=\"https://moj-forms.service.justice.gov.uk/building-and-editing/#check-confirm\">#{warning_text}</a>"
  end
  let(:warning_text) do
    I18n.t("warnings.submission_pages.link.#{page_with_warning}")
  end
  let(:publish_warning) do
    I18n.t(
      "warnings.submission_pages.dev.#{page_with_warning}",
      href: link
    )
  end
  let(:confirmation_uuid) { '778e364b-9a7f-4829-8eb2-510e08f156a3' }
  let(:checkanswers_uuid) { 'e337070b-f636-49a3-a65c-f506675265f0' }
  let(:checkanswers_page) do
    metadata['flow']['e337070b-f636-49a3-a65c-f506675265f0']
  end
  let(:arnold_incomplete_answers) do
    metadata['flow']['941137d7-a1da-43fd-994a-98a4f9ea6d46']
  end
  let(:arnold_right_answers) do
    metadata['flow']['56e80942-d0a4-405a-85cd-bd1b100013d6']
  end
  let(:arnold_wrong_answers) do
    metadata['flow']['6324cca4-7770-4765-89b9-1cdc41f49c8b']
  end
  let(:grid) { MetadataPresenter::Grid.new(service) }

  describe '#message' do
    let(:presenter) do
      SubmissionPagesPresenter.new(service, I18n.t('warnings.submission_pages.dev'), grid)
    end
    context 'check presence of cya and confirmation page' do
      context 'when there is both a check answers and confirmation page' do
        let(:service) { MetadataPresenter::Service.new(latest_metadata) }
        let(:latest_metadata) { metadata_fixture(:branching) }
        it 'returns nil' do
          expect(presenter.message).to be_nil
        end
      end

      context 'when there is no check answers or confirmation page' do
        let(:service) do
          MetadataPresenter::Service.new(metadata_fixture(:exit_only_service))
        end

        let(:page_with_warning) { 'both_pages' }
        it 'returns the correct warning' do
          expect(presenter.message).to eq(publish_warning)
        end
      end
    end

    context 'check presence of cya page' do
      let(:service) { MetadataPresenter::Service.new(latest_metadata) }
      let(:metadata) { metadata_fixture(:branching) }

      context 'when there is no check answers page' do
        let(:latest_metadata) do
          arnold_incomplete_answers['next']['default'] = confirmation_uuid
          arnold_right_answers['next']['default'] = confirmation_uuid
          arnold_wrong_answers['next']['default'] = confirmation_uuid
          metadata['flow'].delete(checkanswers_uuid)
          metadata['pages'] = metadata['pages'].reject do |page|
            page['_uuid'] == checkanswers_uuid
          end
          metadata
        end
        let(:page_with_warning) { 'cya_page' }

        it 'returns the correct warning' do
          expect(presenter.message).to eq(publish_warning)
        end
      end

      context 'when check answers page is disconnected' do
        let(:latest_metadata) do
          arnold_incomplete_answers['next']['default'] = confirmation_uuid
          arnold_right_answers['next']['default'] = confirmation_uuid
          arnold_wrong_answers['next']['default'] = confirmation_uuid
          metadata
        end
        let(:page_with_warning) { 'cya_page' }

        it 'returns the correct message' do
          expect(presenter.message).to eq(publish_warning)
        end
      end
    end

    context 'check presence of confirmation page' do
      let(:service) { MetadataPresenter::Service.new(latest_metadata) }
      let(:metadata) { metadata_fixture(:branching) }

      context 'when there is no confirmation page' do
        let(:latest_metadata) do
          checkanswers_page['next']['default'] = '9e1ba77f-f1e5-42f4-b090-437aa9af7f73' # name
          metadata['flow'].delete(confirmation_uuid)
          metadata['pages'] = metadata['pages'].reject do |page|
            page['_uuid'] == confirmation_uuid
          end
          metadata
        end

        let(:page_with_warning) { 'confirmation_page' }

        it 'returns the correct warning' do
          expect(presenter.message).to eq(publish_warning)
        end
      end

      context 'when confirmation page is disconnected' do
        let(:latest_metadata) do
          checkanswers_page['next']['default'] = ''
          metadata
        end
        let(:page_with_warning) { 'confirmation_page' }

        it 'returns the correct warning' do
          expect(presenter.message).to eq(publish_warning)
        end
      end
    end
  end
end
