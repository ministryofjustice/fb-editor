require 'rails_helper'

RSpec.describe 'Admin maintenance-mode change logging', type: :request do
  let(:metadata) { metadata_fixture(:branching) }
  let(:service) { MetadataPresenter::Service.new(metadata) }
  let(:current_user) { create(:user) }

  before do
    allow_any_instance_of(Admin::ApplicationController).to receive(:require_user!).and_return(true)
    allow_any_instance_of(Admin::ApplicationController).to receive(:current_user).and_return(current_user)
    allow_any_instance_of(Admin::ApplicationController).to receive(:moj_forms_dev?).and_return(true)
    allow(MetadataApiClient::Service).to receive(:latest_version).and_return(metadata)
  end

  # The updater stores a MAINTENANCE_MODE config row only while maintenance mode
  # is on. Seeding one makes the service start out "enabled".
  def enable_maintenance_mode!
    ServiceConfiguration.create!(
      service_id: service.service_id,
      deployment_environment: 'production',
      name: 'MAINTENANCE_MODE',
      value: '1'
    )
  end

  def submit(maintenance_mode:, heading: 'Down for maintenance', content: 'Back soon')
    patch admin_service_path(service.service_id), params: {
      maintenance_mode_settings: {
        maintenance_mode:,
        maintenance_page_heading: heading,
        maintenance_page_content: content
      }
    }
  end

  it 'records an "enabled" event, attributed to the admin, when the switch is turned on' do
    expect { submit(maintenance_mode: '1') }.to change(AdminEvent, :count).by(1)

    event = AdminEvent.recent.first
    expect(event.action).to eq('Maintenance mode enabled')
    expect(event.user_id).to eq(current_user.id)
  end

  it 'records a "disabled" event when the switch is turned off' do
    enable_maintenance_mode!

    expect { submit(maintenance_mode: '0') }.to change(AdminEvent, :count).by(1)

    expect(AdminEvent.recent.first.action).to eq('Maintenance mode disabled')
  end

  it 'does not log when the switch did not move (only heading/content edited)' do
    expect { submit(maintenance_mode: '0', heading: 'New heading') }
      .not_to change(AdminEvent, :count)
  end

  it 'surfaces the maintenance action on the changes page' do
    submit(maintenance_mode: '1')

    get admin_changes_path

    expect(response.body).to include('Maintenance mode enabled')
    expect(response.body).to include(current_user.email)
  end
end
