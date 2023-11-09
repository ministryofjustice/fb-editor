RSpec.describe PublishForReviewDeclarations, type: :model do
  let(:subject) { described_class.new }

  describe 'validations' do
    before do
      subject.checked(params)
    end

    context 'valid' do
      let(:params) do
        %w[
          declaration_1
          declaration_2
          declaration_3
          declaration_4
          declaration_5
          declaration_6
        ]
      end

      it 'should be valid when all declarations are checked' do
        expect(subject.valid?).to eq(true)
      end
    end

    context 'invalid' do
      let(:params) do
        %w[
          declaration_1
        ]
      end

      it 'should not be valid whenany declarations are not checked' do
        expect(subject.valid?).to eq(false)
      end
    end
  end

  describe 'set declarations from params' do
    let(:params) do
      %w[
        declaration_1
        declaration_2
        declaration_3
        declaration_4
        declaration_5
        declaration_6
      ]
    end

    before do
      subject.checked(params)
    end

    it 'should populate all the declarations' do
      expect(subject.declaration_1).to eq(true)
      expect(subject.declaration_2).to eq(true)
      expect(subject.declaration_3).to eq(true)
      expect(subject.declaration_4).to eq(true)
      expect(subject.declaration_5).to eq(true)
      expect(subject.declaration_6).to eq(true)
    end
  end
end
