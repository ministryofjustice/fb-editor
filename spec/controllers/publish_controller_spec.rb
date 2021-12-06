RSpec.describe PublishController do
  before do
    allow(controller).to receive(:service).and_return(service)
  end
  let(:service) { MetadataPresenter::Service.new(latest_metadata) }
  let(:latest_metadata) { metadata_fixture(:branching) }
  let(:checkanswers_uuid) { 'e337070b-f636-49a3-a65c-f506675265f0' }
  let(:confirmation_uuid) { '778e364b-9a7f-4829-8eb2-510e08f156a3' }
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
  let(:warning_both_pages) do
    I18n.t('publish.warning.both_pages')
  end
  let(:warning_cya_page) do
    I18n.t('publish.warning.cya')
  end
  let(:warning_confirmation_page) do
    I18n.t('publish.warning.confirmation')
  end

  describe '#submitting_pages_not_present' do
    context 'when there is both a check answers and confirmation page' do
      it 'returns nil' do
        expect(controller.submitting_pages_not_present).to be_nil
      end
    end

    context 'when there is neither a check answers or confirmation page' do
      let(:service) do
        MetadataPresenter::Service.new(metadata_fixture(:exit_only_service))
      end

      it 'returns the correct warning' do
        expect(controller.submitting_pages_not_present).to eq(warning_both_pages)
      end
    end

    context 'when there is no check answers page' do
      let(:metadata) { metadata_fixture(:branching) }
      let(:latest_metadata) do
        arnold_incomplete_answers['next']['default'] = confirmation_uuid
        arnold_right_answers['next']['default'] = confirmation_uuid
        arnold_wrong_answers['next']['default'] = confirmation_uuid
        metadata
      end

      it 'returns nil' do
        expect(controller.submitting_pages_not_present).to be_nil
      end
    end

    context 'when there is no confirmation page' do
      let(:metadata) { metadata_fixture(:branching) }
      let(:latest_metadata) do
        checkanswers_page['next']['default'] = '9e1ba77f-f1e5-42f4-b090-437aa9af7f73' # name
        metadata
      end

      it 'returns nil' do
        expect(controller.submitting_pages_not_present).to be_nil
      end
    end
  end

  describe '#cya_page_not_present' do
    context 'when there is both a check answers and confirmation page' do
      it 'returns nil' do
        expect(controller.cya_page_not_present).to be_nil
      end
    end

    context 'when there is neither a check answers or confirmation page' do
      let(:service) do
        MetadataPresenter::Service.new(metadata_fixture(:exit_only_service))
      end

      it 'returns nil' do
        expect(controller.cya_page_not_present).to be_nil
      end
    end

    context 'when there is no check answers page' do
      let(:metadata) { metadata_fixture(:branching) }
      let(:latest_metadata) do
        arnold_incomplete_answers['next']['default'] = confirmation_uuid
        arnold_right_answers['next']['default'] = confirmation_uuid
        arnold_wrong_answers['next']['default'] = confirmation_uuid
        metadata
      end

      it 'returns the correct warning' do
        expect(controller.cya_page_not_present).to eq(warning_cya_page)
      end
    end

    context 'when there is no confirmation page' do
      let(:metadata) { metadata_fixture(:branching) }
      let(:latest_metadata) do
        checkanswers_page['next']['default'] = '9e1ba77f-f1e5-42f4-b090-437aa9af7f73' # name
        metadata
      end

      it 'returns nil' do
        expect(controller.cya_page_not_present).to be_nil
      end
    end
  end

  describe '#confirmation_page_not_present' do
    context 'when there is both a check answers and confirmation page' do
      it 'returns nil' do
        expect(controller.confirmation_page_not_present).to be_nil
      end
    end

    context 'when there is neither a check answers or confirmation page' do
      let(:service) do
        MetadataPresenter::Service.new(metadata_fixture(:exit_only_service))
      end

      it 'returns nil' do
        expect(controller.confirmation_page_not_present).to be_nil
      end
    end

    context 'when there is no check answers page' do
      let(:metadata) { metadata_fixture(:branching) }
      let(:latest_metadata) do
        arnold_incomplete_answers['next']['default'] = confirmation_uuid
        arnold_right_answers['next']['default'] = confirmation_uuid
        arnold_wrong_answers['next']['default'] = confirmation_uuid
        metadata
      end

      it 'returns nil' do
        expect(controller.confirmation_page_not_present).to be_nil
      end
    end

    context 'when there is no confirmation page' do
      let(:metadata) { metadata_fixture(:branching) }
      let(:latest_metadata) do
        checkanswers_page['next']['default'] = '9e1ba77f-f1e5-42f4-b090-437aa9af7f73' # name
        metadata
      end

      it 'returns the correct warning' do
        expect(controller.confirmation_page_not_present).to eq(warning_confirmation_page)
      end
    end
  end

  context 'PageCheckHelper' do
    context 'when cya and confirmation pages are in the service' do
      context '#checkanswers_in_service?' do
        it 'should return true' do
          expect(controller.checkanswers_in_service?).to be_truthy
        end
      end

      context '#confirmation_in_service?' do
        it 'should return true' do
          expect(controller.confirmation_in_service?).to be_truthy
        end
      end
    end

    context 'when cya and confirmation pages not are in the service' do
      let(:service) do
        MetadataPresenter::Service.new(metadata_fixture(:exit_only_service))
      end
      context '#checkanswers_in_service?' do
        it 'should return false' do
          expect(controller.checkanswers_in_service?).to be_falsey
        end
      end

      context '#confirmation_in_service?' do
        it 'should return false' do
          expect(controller.confirmation_in_service?).to be_falsey
        end
      end
    end

    context 'when cya is not in the main flow but is in the service' do
      let(:metadata) { metadata_fixture(:branching) }
      let(:latest_metadata) do
        arnold_incomplete_answers['next']['default'] = confirmation_uuid
        arnold_right_answers['next']['default'] = confirmation_uuid
        arnold_wrong_answers['next']['default'] = confirmation_uuid
        metadata
      end

      context '#checkanswers_in_service?' do
        it 'should return true' do
          expect(controller.checkanswers_in_service?).to be_truthy
        end
      end
    end

    context 'when confirmation is not in the main flow but is in the service' do
      let(:metadata) { metadata_fixture(:branching) }
      let(:latest_metadata) do
        checkanswers_page['next']['default'] = '9e1ba77f-f1e5-42f4-b090-437aa9af7f73' # name
        metadata
      end

      context '#confirmation_in_service?' do
        it 'should return true' do
          expect(controller.confirmation_in_service?).to be_truthy
        end
      end
    end
  end
end
