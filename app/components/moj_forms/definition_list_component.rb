module MojForms
  class DefinitionListComponent < GovukComponent::Base
    renders_many :items, DefinitionListItemComponent

    def initialize(classes: [], html_attributes: {})
      super(classes: classes, html_attributes: html_attributes)
    end

    def call
      tag.dl(**html_attributes) do
        if items?
          safe_join(items.collect { |item| item })
        else
          content
        end
      end
    end

    private

    def default_attributes
      { class: %w[mojf-definition-list] }
    end
  end
end
