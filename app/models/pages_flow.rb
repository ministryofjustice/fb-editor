class PagesFlow
  def initialize(service)
    @service = service
    @ordered = []
    @traversed = []
  end

  def build
    flow_groups = ordered_flow.map do |stack|
      stack.grouped_flow_objects.map { |group| convert_flow_objects(group).compact }
    end

    flow_groups.flatten(1).reject(&:empty?)
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
  attr_accessor :ordered, :traversed

  def ordered_flow
    previous_uuid = ''
    next_uuid = service.start_page.uuid

    service.flow.size.times do
      # confirmation page, and in the future exit pages
      next if next_uuid.empty?

      flow_object = service.flow_object(next_uuid)
      add_flow_stack(service.flow_object(previous_uuid), flow_object)

      if flow_object.branch?
        flow_object.conditionals.each do |conditional|
          next_object = service.flow_object(conditional.next)
          add_flow_stack(flow_object, next_object)
        end
      end

      previous_uuid = flow_object.uuid
      next_uuid = flow_object.default_next
    end

    @ordered
  end

  def add_flow_stack(previous, current)
    @ordered.append(
      FlowStack.new(
        service: service,
        previous: previous,
        current: current
      )
    )
  end

  def convert_flow_objects(group)
    group.map do |flow|
      next if @traversed.include?(flow.uuid)

      @traversed.push(flow.uuid)
      flow.type == 'flow.page' ? page(flow) : branch(flow)
    end
  end

  def base_props(obj)
    {
      type: obj.type,
      title: obj.title,
      uuid: obj.uuid,
      thumbnail: thumbnail_type(obj)
    }
  end

  def thumbnail_type(obj)
    if use_flow_type?(obj)
      obj.type.gsub(/(flow|page)./, '')
    else
      obj.components.first.type
    end
  end

  def use_flow_type?(obj)
    obj.components.blank? ||
      obj.branch? ||
      obj.type =~ /page.(start|checkanswers|confirmation)/
  end

  def branch_conditionals(conditionals)
    conditionals.map { |conditional|
      begin
        send("#{conditional.type}_conditional", conditional)
      rescue NoMethodError
        raise NotImplementedError, "'#{conditional.type}' method not implemented"
      end
    }.flatten
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
    expression.service = service
    {
      question: expression.expression_component.humanised_title,
      answer: answer(expression)
    }
  end

  def answer(expression)
    operator = I18n.t("operators.#{expression.operator}")
    "#{operator} #{expression.field_label}".strip
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
