class DisconnectPresenter < WarningPresenter
  attr_reader :destination, :messages

  def initialize(destination)
    @destination = destination
    @messages = {
      both_pages: I18n.t('pages.disconnecting_modal.both_pages'),
      cya_page: I18n.t('pages.disconnecting_modal.cya'),
      confirmation_page: I18n.t('pages.disconnecting_modal.confirmation')
    }
    @service = updated_service
    super(updated_service)
  end

  # we need a service which represents what the metadata WOULD look like
  # if the user changed the destination
  def updated_service
    @updated_service ||=
      MetadataPresenter::Service.new(destination.metadata)
  end
end
