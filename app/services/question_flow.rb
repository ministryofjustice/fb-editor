class QuestionFlow
  QUESTIONS = %i[q1 q2 q3 q4].freeze

  def initialize(answers)
    @answers = answers
  end

  def first
    :q1
  end

  def next(current)
    case current
    when :q1
      @answers[:q1] == 'yes' ? :q2 : :q3
    when :q2
      :q4
    when :q3
      :q4
    end
  end
end
