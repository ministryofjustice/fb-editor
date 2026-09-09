class ComponentSection < SitePrism::Section
  element :up_button, '[data-orderable-item-target="upButton"]'
  element :down_button, '[data-orderable-item-target="downButton"]'
  element :heading, 'h2'
element :editable_content, '[data-element="editable-content-output"] > p'

  # Focuses an editable question or content area
  def activate
    begin
      heading&.click 
    rescue
      editable_content.click
    end
  end
end
