module SetCurrentFormLocale
  extend ActiveSupport::Concern

  included do
    before_action do
      Current.form_locale = service.metadata.locale
    end
  end

  private

  def switch_locale(&action)
    I18n.with_locale(Current.form_locale, &action)
  end
end
