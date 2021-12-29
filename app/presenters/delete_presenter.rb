class DeletePresenter < WarningPresenter
  attr_reader :messages

  def initialize(service)
    @messages = {
      both_pages: I18n.t('pages.flow.delete_warning_both_pages'),
      cya_page: I18n.t('pages.flow.delete_warning_cya_page'),
      confirmation_page: I18n.t('pages.flow.delete_warning_confirmation_page')
    }
    super
  end
end
