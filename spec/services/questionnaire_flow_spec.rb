require 'rails_helper'

RSpec.describe QuestionnaireFlow do
  subject(:flow) { described_class.new(answers) }

  describe '#next' do
    context 'when current page is :get_started' do
      context "and new_form_reason is 'building'" do
        let(:answers) { { 'new_form_reason' => 'building' } }

        it 'goes to :gov_forms' do
          expect(flow.next(:get_started)).to eq(:gov_forms)
        end
      end

      context "and new_form_reason is not 'building'" do
        let(:answers) { { 'new_form_reason' => 'experiment' } }

        it 'goes to :great_choice' do
          expect(flow.next(:get_started)).to eq(:great_choice)
        end
      end
    end

    context 'when current page is :gov_forms' do
      context "and govuk_forms_ruled_out is 'true'" do
        let(:answers) { { 'govuk_forms_ruled_out' => 'true' } }

        it 'goes to :form_features' do
          expect(flow.next(:gov_forms)).to eq(:form_features)
        end
      end

      context "and govuk_forms_ruled_out is not 'true'" do
        let(:answers) { { 'govuk_forms_ruled_out' => 'false' } }

        it 'goes to :continue' do
          expect(flow.next(:gov_forms)).to eq(:continue)
        end
      end
    end

    context 'when current page is :continue' do
      context "and continue_with_moj_forms is 'true'" do
        let(:answers) { { 'continue_with_moj_forms' => 'true' } }

        it 'goes to :new_form' do
          expect(flow.next(:continue)).to eq(:new_form)
        end
      end

      context "and continue_with_moj_forms is not 'true'" do
        let(:answers) { { 'continue_with_moj_forms' => 'false' } }

        it 'goes to :exit' do
          expect(flow.next(:continue)).to eq(:exit)
        end
      end
    end

    context 'when current page is :form_features' do
      let(:answers) { {} }

      it 'goes to :new_form' do
        expect(flow.next(:form_features)).to eq(:new_form)
      end
    end

    context 'when current page is :new_form' do
      let(:answers) { {} }

      it 'goes to :requirements' do
        expect(flow.next(:new_form)).to eq(:requirements)
      end
    end

    context 'when current page is :requirements' do
      let(:answers) { {} }

      it 'returns nil' do
        expect(flow.next(:requirements)).to be_nil
      end
    end

    context 'when current page is :great_choice' do
      let(:answers) { {} }

      it 'returns nil' do
        expect(flow.next(:great_choice)).to be_nil
      end
    end

    context 'when current page is :exit' do
      let(:answers) { {} }

      it 'returns nil' do
        expect(flow.next(:exit)).to be_nil
      end
    end
  end

  describe '#form_class' do
    let(:answers) { {} }

    it 'returns the form class for a valid page' do
      expect(flow.form_class(:get_started))
        .to eq(Questionnaire::GetStartedForm)
    end

    it 'returns nil for an unknown page' do
      expect(flow.form_class(:unknown)).to be_nil
    end
  end

  describe '#param_key' do
    let(:answers) { {} }

    it 'returns the param key for a page with one configured' do
      expect(flow.param_key(:get_started))
        .to eq(:questionnaire_get_started_form)
    end

    it 'returns nil for pages without a param key' do
      expect(flow.param_key(:requirements)).to be_nil
    end

    it 'returns nil for an unknown page' do
      expect(flow.param_key(:unknown)).to be_nil
    end
  end
end
