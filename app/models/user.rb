class User < ApplicationRecord
  has_many :identities, dependent: :destroy

  validate :email_uniqueness

  include UserEncryption

  before_save :encrypt_attributes

  def has_identity?(identity)
    identities.any? do |id|
      id.uid == identity.uid &&
        id.provider == identity.provider
    end
  end

  private

  def email_uniqueness
    return if email.blank?

    if User.where.not(id: id).map(&:email).compact.map(&:downcase).include?(email.downcase)
      errors.add(:base, 'Email already exists')
    end
  end
end
