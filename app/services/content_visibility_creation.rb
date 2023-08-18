class ContentVisibilityCreation
  include MetadataVersion
  include ActiveModel::Model
  delegate :title, :previous_flow_uuid, :version, :service, :conditionals,
  :default_next, to: :conditional_content

  attr_accessor :conditional_content, :latest_metadata

  def save
    return false if conditional_content.invalid? || conditional_content.any_errors?

    # inject conditional into the correct component

    create_version
  end
end
