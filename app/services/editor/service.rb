module Editor
  class Service
    include ActiveModel::Model
    attr_accessor :service_name, :current_user, :questionnaire, :service_id, :latest_metadata

    MINIMUM = 3
    MAXIMUM = 255
    URL_MAXIMUM = 57

    validates :service_name, presence: true
    validates :service_name, length: { minimum: MINIMUM, maximum: MAXIMUM }, allow_blank: true

    def add_errors(service)
      service.errors.each do |_error_message|
        errors.add(:service_name, :taken)
      end
    end
  end
end
