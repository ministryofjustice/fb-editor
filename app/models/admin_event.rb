class AdminEvent < ApplicationRecord
  belongs_to :user, optional: true

  scope :recent, -> { order(created_at: :desc) }
end
