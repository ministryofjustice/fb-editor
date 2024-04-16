class Announcement < ApplicationRecord
  belongs_to :created_by, class_name: 'User'
  belongs_to :revoked_by, class_name: 'User', optional: true

  scope :scheduled, lambda {
    where(['date_from <= ?', Date.current])
    .where(['date_to >= ? OR date_to IS ?', Date.current, nil])
  }
  scope :non_revoked, -> { where(revoked_at: nil) }
  scope :candidates,  -> { scheduled.non_revoked.order(created_at: :desc) }

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
