RSpec.describe ExternalStartPageUrl do
  let(:subject) { described_class.new }

  describe '#validate' do
    let(:valid_urls) do
      [
        'gov.uk',
        'gov.uk/',
        '/gov.uk',
        '/gov.uk/example',
        'subdomain.gov.uk',
        'www.gov.uk',
        'https://gov.uk',
        'https://www.gov.uk',
      ]
    end

    it 'is invalid when url is blank' do
      expect(subject.valid?).to be(false)
    end

    it 'is invalid when not a gov uk url' do
      subject.url = 'example.com'

      expect(subject.valid?).to be(false)
    end

    it 'validates gov.uk' do
      valid_urls.each do |url|
        subject.url = url
        expect(subject.valid?).to be(true)
      end
    end
  end
end