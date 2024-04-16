require 'rails_helper'

RSpec.describe Announcement, type: :model do
  subject { described_class.new(attributes) }

  let(:attributes) do
    {
      created_by: user,
      revoked_at:,
      revoked_by: nil,
      title: 'Info',
      content: 'This is a test announcement',
      date_from:,
      date_to:
    }
  end

  let(:user) { build(:user) }
  let(:date_from) { Date.current }
  let(:date_to) { nil }
  let(:revoked_at) { nil }

  describe 'validations' do
    before do
      subject.valid?
    end

    context 'required attributes' do
      let(:attributes) { super().merge(title: nil, content: nil, date_from: nil) }

      it 'requires a title' do
        expect(subject.errors.of_kind?(:title, :blank)).to be(true)
      end

      it 'requires the content' do
        expect(subject.errors.of_kind?(:content, :blank)).to be(true)
      end

      it 'requires a start date' do
        expect(subject.errors.of_kind?(:date_from, :blank)).to be(true)
      end
    end

    context 'date validations' do
      context 'date_from' do
        let(:date_to) { nil }

        context '`date_from` equal than today' do
          let(:date_from) { Date.current }

          it { is_expected.to be_valid }
        end

        context '`date_from` greater than today' do
          let(:date_from) { Date.tomorrow }

          it { is_expected.to be_valid }
        end

        context '`date_from` is in the past' do
          let(:date_from) { Date.yesterday }

          it { is_expected.not_to be_valid }
        end
      end

      context 'date_to' do
        let(:date_from) { Date.current }

        context '`date_to` equal than `date_from`' do
          let(:date_to) { Date.current }

          it { is_expected.to be_valid }
        end

        context '`date_to` greater than `date_from`' do
          let(:date_to) { Date.tomorrow }

          it { is_expected.to be_valid }
        end

        context '`date_to` is before `date_from`' do
          let(:date_to) { Date.yesterday }

          it { is_expected.not_to be_valid }
        end
      end
    end
  end

  describe '#expired?' do
    context '`date_to` is nil' do
      let(:date_to) { nil }

      it { is_expected.not_to be_expired }
    end

    context '`date_to` is today' do
      let(:date_to) { Date.current }

      it { is_expected.not_to be_expired }
    end

    context '`date_to` is tomorrow' do
      let(:date_to) { Date.tomorrow }

      it { is_expected.not_to be_expired }
    end

    context '`date_to` is in the past' do
      let(:date_to) { Date.yesterday }

      it { is_expected.to be_expired }
    end
  end

  describe '#editable?' do
    before do
      allow(subject).to receive(:expired?).and_return(expired)
      allow(subject).to receive(:revoked?).and_return(revoked)
    end

    let(:expired) { false }
    let(:revoked) { false }

    context 'when announcement is expired' do
      let(:expired) { true }

      it { is_expected.not_to be_editable }
    end

    context 'when announcement is revoked' do
      let(:revoked) { true }

      it { is_expected.not_to be_editable }
    end

    context 'when announcement is not last one created' do
      it { is_expected.not_to be_editable }
    end

    context 'when otherwise' do
      it 'is editable' do
        expect(Announcement).to receive(:first).and_return(subject)
        is_expected.to be_editable
      end
    end
  end

  describe '#revoked?' do
    context 'when there is a `revoked_at` date' do
      let(:revoked_at) { Date.current }

      it { is_expected.to be_revoked }
    end

    context 'when `revoked_at` is nil' do
      it { is_expected.not_to be_revoked }
    end
  end

  describe '#revoke!' do
    before do
      freeze_time
    end

    it 'sets the revoked_by and revoked_at attributes' do
      expect {
        subject.revoke!(user)
      }.to change { subject.revoked_by }.from(nil).to(user)
      .and change { subject.revoked_at }.from(nil).to(Time.current)
    end
  end
end
