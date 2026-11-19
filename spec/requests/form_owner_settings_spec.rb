require 'rails_helper'

RSpec.describe 'Transferring form ownership', type: :request do
  let(:previous_owner) { create(:user, email: 'bishop@sulaco.com') }
  let(:new_owner) { create(:user, email: 'peter.quill@milano.com') }
  let(:metadata) { metadata_fixture(:branching).merge('created_by' => previous_owner.id) }

  before do
    allow_any_instance_of(PermissionsController).to receive(:require_user!).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:service_metadata).and_return(metadata)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(previous_owner)
    allow(MetadataApiClient::Version).to receive(:create).and_return(double(errors?: false))
  end

  def transfer(to:)
    put "/services/#{metadata['service_id']}/settings/form_owner",
        params: { form_owner_settings: { form_owner: to } }
  end

  it 'records an admin event attributed to the user who made the transfer' do
    expect { transfer(to: new_owner.email) }.to change(AdminEvent, :count).by(1)

    expect(AdminEvent.last).to have_attributes(
      action: 'Form ownership transferred from bishop@sulaco.com to peter.quill@milano.com',
      user_id: previous_owner.id,
      service_id: metadata['service_id']
    )
  end

  it 'does not record an event when the transfer fails' do
    expect { transfer(to: 'unknown@example.com') }.not_to change(AdminEvent, :count)
  end
end
