require 'rails_helper'

RSpec.describe 'Admin metadata ownership change logging', type: :request do
  let(:admin) { create(:user, email: 'peter.quill@milano.com') }
  let(:previous_owner) { create(:user, email: 'bishop@sulaco.com') }
  let(:new_owner) { create(:user, email: 'jane.smith@digital.justice.gov.uk') }
  let(:metadata) { metadata_fixture(:branching).merge('created_by' => previous_owner.id) }
  let(:service_id) { metadata['service_id'] }

  before do
    allow_any_instance_of(Admin::ApplicationController).to receive(:require_user!).and_return(true)
    allow_any_instance_of(Admin::ApplicationController).to receive(:current_user).and_return(admin)
    allow_any_instance_of(Admin::ApplicationController).to receive(:moj_forms_dev?).and_return(true)
    allow(MetadataApiClient::Service).to receive(:latest_version).and_return(metadata)
    allow(MetadataApiClient::Version).to receive(:create).and_return(double(errors?: false, metadata: {}))
  end

  def save_metadata(created_by:)
    patch admin_service_version_path(service_id, SecureRandom.uuid),
          params: { version: metadata.merge('created_by' => created_by).to_json }
  end

  it 'records an admin event, attributed to the admin, when created_by changes' do
    expect { save_metadata(created_by: new_owner.id) }.to change(AdminEvent, :count).by(1)

    expect(AdminEvent.last).to have_attributes(
      action: 'Form ownership transferred from bishop@sulaco.com to jane.smith@digital.justice.gov.uk',
      user_id: admin.id,
      service_id:
    )
  end

  it 'does not record an event when created_by is unchanged' do
    expect { save_metadata(created_by: previous_owner.id) }.not_to change(AdminEvent, :count)
  end
end
