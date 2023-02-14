module MojForms
  class SettingsScreenComponent < GovukComponent::Base
    renders_one :back_link, MojForms::BackLinkComponent
    renders_one :notification

    def initialize(heading:, description: '', classes: [], html_attributes: {})
      @heading = heading
      @description = description

      @header_classes = @description ? 'with-description' : ''

      super(classes:, html_attributes:)
    end

    private

    def default_attributes
      { class: %w[mojf-settings-screen] }
    end
  end
end
