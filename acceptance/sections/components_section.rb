require_relative './component_section'

class ComponentsSection < SitePrism::Section
  sections :components, ComponentSection, '[data-controller*="component"]'
  # elements :question_components, '.Question'

  def component_titles
    components.map do |c|
      c.heading&.text rescue 'editable_content'
    end
  end

  def first_component
    component(0)
  end

  def second_component
    component(1)
  end

  def last_component
    component(components.size-1)
  end

  def component(index) 
    components[index]
  end
end
