module SetCurrentFormLocale
  extend ActiveSupport::Concern

  included do
    before_action do
      Current.form_locale = service.metadata.locale
    end
  end
end
