class Questionnaire::ContinueForm
  include ActiveModel::API
  attr_accessor :continue_with_moj_forms

  validates :continue_with_moj_forms,
            presence: true,
            inclusion: { in: %w[true false] }
end
