module Editor
  class Service
    include ActiveModel::Model
    attr_accessor :service_name, :current_user, :service_id, :latest_metadata

    MINIMUM = 3
    MAXIMUM = ENV['NAME_SLUG'] == 'enabled' ? 255 : 57
    URL_MAXIMUM = 57

    validates :service_name, presence: true
    validates :service_name, length: { minimum: MINIMUM, maximum: MAXIMUM }, allow_blank: true
    validates :service_name, format: { with: /\A[a-zA-Z][\sa-zA-Z0-9-'’()]*\z/ }, allow_blank: true
    validates :service_name, legacy_service_name: true

    def add_errors(service)
      service.errors.each do |_error_message|
        errors.add(:service_name, :taken)
      end
    end
  end
end
