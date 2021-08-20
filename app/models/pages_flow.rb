class PagesFlow
  def initialize(service)
    @service = service
  end

  def build
    ordered_flow.map { |flow| flow.type == 'flow.page' ? page(flow) : branch(flow) }
  end

  def page(flow)
    page = service.find_page_by_uuid(flow.uuid)
    base_props(page).merge(next: flow.default_next)
  end

  def branch(flow)
    base_props(flow).merge(
      conditionals: branch_conditionals(
        flow.conditionals
      ).push(otherwise(flow.default_next))
    )
  end

  private

  attr_reader :service

  def ordered_flow
    next_uuid = service.start_page.uuid
    ordered = []

    service.flow.size.times do
      # confirmation page, and in the future exit pages
      next if next_uuid.empty?

      flow_object = service.flow_object(next_uuid)
      ordered.append(flow_object)

      if flow_object.branch?
        flow_object.conditionals.each do |conditional|
          next_object = service.flow_object(conditional.next)
          ordered.append(next_object)
        end
      end

      next_uuid = flow_object.default_next
    end

    ordered
  end

  def base_props(obj)
    {
      type: obj.type,
      title: obj.title,
      uuid: obj.uuid
    }
  end

  def branch_conditionals(conditionals)
    conditionals.map { |conditional|
      send("#{conditional.type}_conditional", conditional)
    }.flatten
  rescue NoMethodError
    # do something here
  end

  def if_conditional(conditional)
    {
      next: conditional.next,
      expressions: conditional_expressions(conditional)
    }
  end
  alias_method :and_conditional, :if_conditional

  def or_conditional(conditional)
    conditional.expressions.map do |expression|
      {
        next: conditional.next,
        expressions: [question_and_answer(expression)]
      }
    end
  end

  def conditional_expressions(conditional)
    conditional.expressions.map do |expression|
      question_and_answer(expression)
    end
  end

  def question_and_answer(expression)
    page = service.find_page_by_uuid(expression.page)
    component = page.find_component_by_uuid(expression.component)
    item = component.find_item_by_uuid(expression.field) if expression.field.present?
    operator = I18n.t("operators.#{expression.operator}")

    {
      question: component.humanised_title,
      answer: "#{operator} #{item&.label || ''}".strip
    }
  end

  def otherwise(default_next)
    {
      next: default_next,
      expressions: [
        {
          question: I18n.t('activemodel.attributes.branch.default_next'),
          answer: ''
        }
      ]
    }
  end
end
