RSpec.describe PublishingPagePresenter do
  subject(:publishing_page_presenter) { described_class.new(service, deployment_environment) }
  let(:deployment_environment) { 'dev' }

  describe '#from_address_presenter' do
    it 'returns an instance of a from address presenter' do
      expect(subject.from_address_presenter).to be_a FromAddressPresenter
    end
  end

  describe '#publish_creation' do
    it 'returns an instance of a publish creation' do
      expect(subject.publish_creation).to be_a PublishServiceCreation
    end
  end

  describe '#submission_warnings' do
    it 'returns an instance of submission warnings' do
      expect(subject.submission_warnings).to be_a SubmissionWarningsPresenter
    end

    context 'submission warning presenters' do
      let(:presenters) do
        [submission_pages_presenter, from_address_presenter]
      end
      let(:submission_pages_presenter) { double }
      let(:from_address_presenter) { double }

      before do
        allow(subject).to receive(:submission_pages_presenter).and_return(submission_pages_presenter)
        allow(subject).to receive(:from_address_presenter).and_return(from_address_presenter)
      end
      it 'returns the expected presenters' do
        expect(subject.submission_warnings.presenters).to match_array(presenters)
      end
    end
  end
end
