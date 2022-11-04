module MojForms
  class DefinitionListComponent < GovukComponent::Base

    def initialize(classes: [], html_attributes: {})
      super(classes: classes, html_attributes: html_attributes)
    end

    def call
      tag.dl(**html_attributes) do
        content
      end
    end

    private

    def default_attributes
      { class: %w[mojf-definition-list]}
    end
  end
end
