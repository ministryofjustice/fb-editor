# Save Button Component
# =====================
#
# Outputs a custom button element that has dynamic behaviour that tracks changes
# to the form it is contained within.
# See app/javascript/src/web-comoponents/save-button.js
#
# Usage:
# ------
# The intention is to create a save button within a form, so this should be used
# within a FormBuilder and requires the form object to be passed.
#
# <%= MojForms::SaveButtonComponent.new(form: f, text: 'Label') %>
#
# or
#
# <%= mojf_save_button(form: f) do %>
#     Label
# <% end %>
#
# will output
#
# <button is="save-button"
#         type="submit"
#         class="govuk-button fb-govuk-button"
#         data-module="govuk-button">
#   Label
# </button>
#
# See app/javascript/src/web-comoponents/save-button.js for other attributes and
# options that can be used.
#
module MojForms
  class SaveButtonComponent < GovukComponent::Base
    attr_reader :text, :form, :html_attributes

    def initialize(form:, text: '', classes: [], html_attributes: {})
      @form = form
      @text = text
      @html_attributes = html_attributes

      super(classes:, html_attributes:)
    end

    # Translations are not accessible outside of the view context so we use
    # before_render to modify the attributes with our default labels.
    def before_render
      @text ||= t('actions.save')
      @html_attributes = {
        data: {
          saved_label: t('actions.saved'),
          unsaved_label: t('actions.save'),
          saving_label: t('actions.saving'),
          assistive_text: t('aria.disabled_save_description')
        }
      }.deep_merge(@html_attributes)
    end

    def call
      tag.button button_content, **html_attributes
    end

    def button_content
      content || text || raise(ArgumentError, 'no text or content')
    end

    # If the form object has errrors, the save-required attribute will be
    # present - ensuring the button is enabled.  Otherwise the attribute will
    # not be included.
    def default_attributes
      {
        class: %w[govuk-button fb-govuk-button],
        data: {
          module: 'govuk-button'
        },
        is: 'save-button',
        type: 'submit',
        'save-required': ('true' if form.object.errors.any?)
      }.compact
    end
  end
end
