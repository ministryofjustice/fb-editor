class ExternalStartPageUrl
  include ActiveModel::Model

  attr_accessor :url

  validates_with ExternalUrlValidator
end
