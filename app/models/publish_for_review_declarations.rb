class PublishForReviewDeclarations
  include ActiveModel::Model

  attr_accessor :declaration_1, :declaration_2, :declaration_3, :declaration_4, :declaration_5, :declaration_6, :declarations_checkboxes

  validate :all_declarations_selected

  def checked(params)
    @declaration_1 = params.include?('declaration_1')
    @declaration_2 = params.include?('declaration_2')
    @declaration_3 = params.include?('declaration_3')
    @declaration_4 = params.include?('declaration_4')
    @declaration_5 = params.include?('declaration_5')
    @declaration_6 = params.include?('declaration_6')
  end

  def all_declarations_selected
    unless @declaration_1.present? &&
        @declaration_2.present? &&
        @declaration_3.present? &&
        @declaration_4.present? &&
        @declaration_5.present? &&
        @declaration_6.present?
      errors.add(:declarations_checkboxes, I18n.t('publish.declarations.error'))
    end
  end
end
