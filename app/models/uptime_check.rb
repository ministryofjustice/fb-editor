class UptimeCheck < ApplicationRecord
  validates :service_id, :check_id, presence: true
end
