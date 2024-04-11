class FormOwnerSettings
  include ActiveModel::Model
  attr_accessor :form_owner

  validates :form_owner, presence: true

  def initialize(service_id:)
    @service_id = service_id
    @form_owner = get_form_owner
  end

  def get_form_owner
    # 'This will call the version metadata and get field created_by'
  end
end
