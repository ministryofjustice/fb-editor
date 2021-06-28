RSpec.describe Preview::SessionDataAdapter do
  subject(:session_adapter) do
    described_class.new(session, service_id)
  end
  let(:service_id) { SecureRandom.uuid }

  describe '#save(answers)' do
    let(:session) { {} }

    before do
      session_adapter.save(answers)
    end

    context 'new answers' do
      let(:answers) do
        {
          'leonard' => 'these tracks are just a few days old',
          'teddy' => 'what are you, pocahontas?'
        }
      end

      it 'saves new answers to the session under the correct service id' do
        expect(session).to eq(
          {
            service_id => {
              'user_data' => {
                'leonard' => 'these tracks are just a few days old',
                'teddy' => 'what are you, pocahontas?'
              }
            }
          }
        )
      end
    end

    context 'existing answer' do
      let(:session) do
        {
          service_id => {
            'user_data' => {
              'teddy' => 'lenny',
              'leonard' => "it's leonard"
            }
          }
        }
      end
      let(:answers) { { 'teddy' => 'leonard' } }

      it 'updates the answer correctly' do
        expect(session).to eq(
          {
            service_id => {
              'user_data' => {
                'teddy' => 'leonard',
                'leonard' => "it's leonard"
              }
            }
          }
        )
      end
    end

    context 'without answers' do
      let(:answers) { {} }

      it 'returns and empty hash' do
        expect(session_adapter.save(answers)).to eq({})
      end
    end
  end

  describe '#load_data' do
    context 'with existing session data' do
      let(:session) do
        {
          service_id => {
            'user_data' => {
              'leonard' => "i can't remember to forget you"
            }
          },
          '1234' => {
            'user_data' => {
              'some' => 'other data'
            }
          }
        }
      end

      it 'loads the correct service user data' do
        expect(session_adapter.load_data).to eq(
          { 'leonard' => "i can't remember to forget you" }
        )
      end
    end

    context 'without existing session data' do
      let(:session) { {} }

      it 'returns and empty hash' do
        expect(session).to eq({})
      end
    end
  end

  describe '#delete' do
    let(:session) do
      {
        service_id => {
          'user_data' => {
            'to_delete' => 'John G',
            'to_keep' => 'consider the source'
          }
        }
      }
    end

    before do
      session_adapter.delete('to_delete')
    end

    it 'deletes the data by component id' do
      expect(session).to eq(
        {
          service_id => {
            'user_data' => {
              'to_keep' => 'consider the source'
            }
          }
        }
      )
    end
  end
end
