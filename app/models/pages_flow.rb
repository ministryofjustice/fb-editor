class PageMissingComponentError < StandardError
end

class PagesFlow
  def initialize(service)
    @service = service
    @grid = MetadataPresenter::Grid.new(service)
    @traversed = []
  end

  def build
    grid.build.map { |column| convert_flow_objects(column).compact }
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

  def detached_objects
    Detached.new(
      service: service,
      ordered_flow: grid.ordered_flow
    ).flow_objects.map do |flow|
      convert_flow_object(flow)
    end
  end

  private

  attr_reader :service, :grid
  attr_accessor :traversed

  def convert_flow_objects(column)
    column.map do |flow|
      next if @traversed.include?(flow.uuid)

      @traversed.push(flow.uuid) unless flow.is_a?(MetadataPresenter::Spacer)
      convert_flow_object(flow)
    end
  end

  def convert_flow_object(flow)
    return spacer if flow.is_a?(MetadataPresenter::Spacer)

    flow.type == 'flow.page' ? page(flow) : branch(flow)
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

  def spacer
    { type: 'spacer' }
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
    component = expression.expression_component
    alert_missing_component(expression) if component.nil?

    {
      question: component.humanised_title,
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

  def alert_missing_component(expression)
    page_uuid = expression.expression_page.uuid
    component_uuid = expression.component

    error = PageMissingComponentError.new(
      "Page #{page_uuid} does not contain component #{component_uuid}"
    )
    Sentry.capture_exception(error)
    raise error
  end
end
