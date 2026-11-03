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
    if User.all.collect(&:email).include? self['email']
      errors.add(:base, 'Email already exists')
    end
  end
end
