module MojForms
  class DefinitionListItemComponent < GovukComponent::Base
    include GovukLinkHelper

    attr_reader :title, :href, :description

    def initialize(title: , href: , description: , classes: [], html_attributes: {} )
      @title = title
      @href = href
      @description = description
      super(classes:classes, html_attributes: html_attributes)
    end

    def call
      tag.div(**html_attributes) do
       safe_join([dt, dd])
      end
    end

    private

    def dt
      tag.dt govuk_link_to(title, href)
    end

    def dd
      tag.dd description, class: 'govuk-hint'
    end

    def default_attributes
      { class: %w[mojf-definition-list__item]}
    end
  end
end
