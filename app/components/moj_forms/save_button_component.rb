module MojForms
  class SaveButtonComponent < GovukComponent::Base
    attr_reader :text, :form, :html_attributes

    def initialize(form:, text: '', classes: [], html_attributes:{})
      @form = form
      @text = text
      @html_attributes = html_attributes

      super(classes:, html_attributes:)
    end

    def before_render
      @text = (@text || t('actions.save'))
      @html_attributes = { 
        data: { 
          saved_label: t('actions.saved'),
          unsaved_label: t('actions.save'),
          saving_label: t('actions.saving'),
          assistive_text: t('aria.disabled_save_description'),
        }
      }.deep_merge(@html_attributes)
    end

    def call
      tag.button button_content, **html_attributes 
    end

    def button_content
      content || text || raise(ArgumentError, 'no text or content')
    end

    def default_attributes
      { 
        class: %w[govuk-button fb-govuk-button],
        data: { 
          module: 'govuk-button',
        },
        is: 'save-button',
        type: 'submit',
        'save-required': ('true' if form.object.errors.any? )
      }.compact
    end
  end
end
