class Announcement < ApplicationRecord
  belongs_to :created_by, class_name: 'User'
  belongs_to :revoked_by, class_name: 'User', optional: true

  validates :title, :content, :date_from, presence: true
  validates :date_from, comparison: { greater_than_or_equal_to: ->(_) { Date.current } }
  validates :date_to, comparison: { greater_than_or_equal_to: :date_from }, allow_nil: true

  def expired?
    date_to.present? && date_to < Date.current
  end

  def revoked?
    !!revoked_at
  end

  def revoke!(user)
    update(revoked_by: user, revoked_at: Time.current)
  end
end
