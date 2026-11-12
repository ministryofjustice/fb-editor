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

        it 'is not valid when matching case insensitively' do
          user.email = 'TEST@EXAMPLE.COM'
          expect(user).not_to be_valid
          expect(user.errors[:base]).to include('Email already exists')
        end
      end

      context 'when updating an existing user without changing email' do
        let!(:existing_user) { described_class.create!(name: 'Existing User', email: 'test@example.com') }

        it 'is valid when saving the same email' do
          existing_user.email = 'test@example.com'
          expect(existing_user).to be_valid
        end

        it 'is valid when updating timezone' do
          existing_user.timezone = 'UTC'
          expect(existing_user).to be_valid
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

    context 'when updating timezone' do
      it 'does not re-encrypt or change name and email in the database' do
        raw_user_before = described_class.find(user.id)
        raw_name_before = raw_user_before.raw_name
        raw_email_before = raw_user_before.raw_email

        user.update!(timezone: 'UTC')

        raw_user_after = described_class.find(user.id)
        expect(raw_user_after.raw_name).to eq(raw_name_before)
        expect(raw_user_after.raw_email).to eq(raw_email_before)
      end
    end

    context 'when updating email' do
      it 'encrypts the new email in the database' do
        user.update!(email: 'newemail@example.com')
        raw_user = described_class.find(user.id)
        expect(raw_user.raw_email).not_to eq('newemail@example.com')
        expect(user.reload.email).to eq('newemail@example.com')
      end
    end

    context 'when updating name' do
      it 'encrypts the new name in the database' do
        user.update!(name: 'Jane Doe')
        raw_user = described_class.find(user.id)
        expect(raw_user.raw_name).not_to eq('Jane Doe')
        expect(user.reload.name).to eq('Jane Doe')
      end
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
