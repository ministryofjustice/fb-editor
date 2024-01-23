require 'rails_helper'

describe HostEnv do
  describe 'local machine environment' do
    context 'local development rails environment' do
      before do
        allow(Rails.env).to receive_messages(development?: true, test?: false)
      end

      describe '.test?' do
        it 'returns false' do
          expect(described_class.test?).to be false
        end
      end

      describe '.live?' do
        it 'returns false' do
          expect(described_class.live?).to be false
        end
      end

      describe '.local?' do
        it 'returns true' do
          expect(described_class.local?).to be true
        end
      end
    end

    context 'local test rails environment' do
      describe '.test?' do
        it 'returns false' do
          expect(described_class.test?).to be false
        end
      end

      describe '.live?' do
        it 'returns true' do
          expect(described_class.live?).to be false
        end
      end

      describe '.local?' do
        it 'returns false' do
          expect(described_class.local?).to be true
        end
      end
    end
  end

  describe 'PLATFORM_ENV variable is set in production envs' do
    before do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
      allow(ENV).to receive(:fetch).with('PLATFORM_ENV').and_return(env_name)
    end

    context 'test host' do
      let(:env_name) { HostEnv::TEST }

      it { expect(described_class.local?).to be(false) }
      it { expect(described_class.test?).to be(true) }
      it { expect(described_class.live?).to be(false) }
    end

    context 'live host' do
      let(:env_name) { HostEnv::LIVE }

      it { expect(described_class.local?).to be(false) }
      it { expect(described_class.test?).to be(false) }
      it { expect(described_class.live?).to be(true) }
    end

    context 'unknown host' do
      let(:env_name) { 'foobar' }

      it { expect(described_class.local?).to be(false) }
      it { expect(described_class.test?).to be(false) }
      it { expect(described_class.live?).to be(false) }
    end
  end
end
