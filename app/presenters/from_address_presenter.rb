class FromAddressPresenter
  def initialize(from_address, controller)
    @from_address = from_address
    @controller = controller
  end

  MESSAGES = {
    from_address: {
      verified: I18n.t('settings.from_address.messages.verified'),
      pending: I18n.t('settings.from_address.messages.pending'),
      default: I18n.t('settings.from_address.messages.default')
    },
    publish: {
      verified: I18n.t('publish.from_address.messages.verified'),
      pending: I18n.t('publish.from_address.messages.pending'),
      default: I18n.t('publish.from_address.messages.default')
    }
  }.freeze

  def message
    key = from_address.status&.to_sym || :default

    {
      text: MESSAGES[@controller][key],
      status: from_address.status
    }
  end

  private

  attr_reader :from_address
end
