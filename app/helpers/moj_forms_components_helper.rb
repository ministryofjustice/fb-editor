module MojFormsComponentsHelper
  {
    mojf_settings_screen: 'MojForms::SettingsScreenComponent',
    mojf_back_link: 'MojForms::BackLinkComnponent',
    mojf_definition_list: 'MojForms::DefinitionListComponent',
    mojf_definition_list_item: 'MojForms::DefinitionListItemComponent'
  }.each do |name, klass|
    define_method(name) do |*args, **kwargs, &block|
      capture do
        render(klass.constantize.new(*args, **kwargs)) do |com|
          block.call(com) if block.present?
        end
      end
    end
  end
end
