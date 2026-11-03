require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { described_class.new(name: 'Test User', email: 'test@example.com') }

  describe 'associations' do
    let!(:user) { described_class.create!(name: 'Test User', email: 'test@example.com') }
    let!(:identity) { Identity.create!(user: user, uid: '12345', provider: 'auth0') }

    it 'has many identities' do
      expect(user.identities).to include(identity)
    end

    it 'destroys associated identities when user is destroyed' do
      expect { user.destroy }.to change(Identity, :count).by(-1)
    end
  end

  describe 'validations' do
    describe '#email_uniqueness' do
      context 'when email is not taken' do
        it 'is valid' do
          expect(user).to be_valid
        end
      end

      context 'when email already exists' do
        before do
          described_class.create!(name: 'Existing User', email: 'test@example.com')
        end

        it 'is not valid' do
          expect(user).not_to be_valid
        end

        it 'adds an error to base' do
          user.valid?
          expect(user.errors[:base]).to include('Email already exists')
        end
      end
    end
  end

  describe 'encryption' do
    let(:user) { described_class.create!(name: 'John Doe', email: 'john@example.com') }

    it 'encrypts name and email in the database' do
      raw_user = described_class.find(user.id)
      expect(raw_user.raw_name).not_to eq('John Doe')
      expect(raw_user.raw_email).not_to eq('john@example.com')
    end

    it 'decrypts name and email when accessed' do
      raw_user = described_class.find(user.id)
      expect(raw_user.name).to eq('John Doe')
      expect(raw_user.email).to eq('john@example.com')
    end
  end

  describe '#has_identity?' do
    let(:user) { described_class.create!(name: 'Test User', email: 'test@example.com') }
    let(:identity) { Identity.new(uid: 'myuid', provider: 'myprovider') }

    context 'when no identity exists with the given uid & provider' do
      it 'returns false' do
        expect(user.has_identity?(identity)).to be(false)
      end
    end

    context 'when an identity exists with the given uid & provider' do
      before do
        user.identities << identity
      end

      it 'returns true' do
        expect(user.has_identity?(identity)).to be(true)
      end
    end

    context 'when an identity exists with matching uid but different provider' do
      before do
        user.identities << Identity.new(uid: 'myuid', provider: 'otherprovider')
      end

      it 'returns false' do
        expect(user.has_identity?(identity)).to be(false)
      end
    end

    context 'when an identity exists with matching provider but different uid' do
      before do
        user.identities << Identity.new(uid: 'otheruid', provider: 'myprovider')
      end

      it 'returns false' do
        expect(user.has_identity?(identity)).to be(false)
      end
    end
  end
end
