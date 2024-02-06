require 'rails_helper'

RSpec.describe 'Welsh localisation', type: :request do
  let(:current_user) { double(id: service.created_by, email: 'peter.quill@milano.com') }

  let(:service) do
    service = super().dup
    service.metadata.locale = 'cy'
    service
  end

  before do
    allow_any_instance_of(
      PermissionsController
    ).to receive(:require_user!).and_return(true)

    expect_any_instance_of(
      ApplicationController
    ).to receive(:service).at_least(:once).and_return(service)

    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(current_user)
  end

  describe 'service preview' do
    before { get "/services/#{service.service_id}/preview" }

    it 'responds successfully' do
      expect(response.status).to be(200)
    end

    context 'html lang' do
      it 'declares the language in the html tag' do
        assert_select 'html[lang=cy]'
      end
    end

    context 'start button' do
      it 'has a start button translated to Welsh' do
        assert_select 'button.govuk-button--start', 'Dechrau nawr'
      end
    end

    context 'footer links' do
      it 'has the links translated to Welsh' do
        assert_select 'ul.govuk-footer__inline-list' do
          assert_select 'li:nth-child(1) > a', 'Cwcis'
          assert_select 'li:nth-child(2) > a', 'Preifatrwydd'
          assert_select 'li:nth-child(3) > a', 'Hygyrchedd'
        end
      end
    end
  end

  describe 'edit a question page' do
    let(:page_uuid) { '9e1ba77f-f1e5-42f4-b090-437aa9af7f73' }

    before { get "/services/#{service.service_id}/pages/#{page_uuid}/edit" }

    it 'responds successfully' do
      expect(response.status).to be(200)
    end

    context 'html lang' do
      it 'does not change the language tag' do
        assert_select 'html[lang=en]'
      end
    end

    context 'question buttons' do
      it 'has a disabled continue button translated to Welsh' do
        assert_select 'div.govuk-button-group' do
          assert_select 'button.govuk-button--disabled', 'Parhau'
        end
      end
    end
  end
end
