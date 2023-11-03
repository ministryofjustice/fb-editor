class PublishForReviewDeclarations
  include ActiveModel::Model

  attr_accessor :declaration_1, :declaration_2, :declaration_3, :declaration_4, :declaration_5, :declaration_6, :declarations_checkboxes

  validates :declaration_1, :declaration_2, :declaration_3, :declaration_4, :declaration_5, :declaration_6, presence: true

  def checked(params)
    @declaration_1 = params.include?('declaration_1')
    @declaration_2 = params.include?('declaration_2')
    @declaration_3 = params.include?('declaration_3')
    @declaration_4 = params.include?('declaration_4')
    @declaration_5 = params.include?('declaration_5')
    @declaration_6 = params.include?('declaration_6')
  end
end
