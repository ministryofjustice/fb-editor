class ExternalStartPageUrl
  include ActiveModel::Model

  attr_accessor :url

  validates :url, presence: true
end