RSpec.describe LegacyServiceName, type: :model do
  describe 'validations' do
    context 'name' do
      it 'do not allow blank' do
        should_not allow_values('').for(:name)
      end
    end
  end
end
