class PublishPresenter < WarningPresenter
  attr_reader :messages

  def initialize(service)
    @messages = {
      both_pages: I18n.t('publish.warning.both_pages'),
      cya_page: I18n.t('publish.warning.cya'),
      confirmation_page: I18n.t('publish.warning.confirmation')
    }
    super
  end
end
