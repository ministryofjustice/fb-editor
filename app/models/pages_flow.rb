class PageMissingComponentError < StandardError
end

class PagesFlow
  include ApplicationHelper

  def initialize(service)
    @service = service
    @grid = MetadataPresenter::Grid.new(service)
    @traversed = []
  end

  def build
    grid.build.map { |column| convert_flow_objects(column).compact }
  end

  def detached_flows
    detached = Detached.new(service:, main_flow_uuids: grid.flow_uuids)
    detached.detached_flows.map do |detached_flow|
      detached_flow.map do |column|
        column.map do |flow|
          # byebug
          # todo : we should not add :
          # convert_flow_object(flow) = {:type=>"pointer", :uuid=>"e184ce91-0b0e-4fb0-b05b-f2113281ea94", :title=>"Application complete"}
          converted_flow_object = convert_flow_object(flow)
          next if converted_flow_object[:title] == 'Application complete'
          next if converted_flow_object[:title] == 'Check your answers'
          converted_flow_object
          # convert_flow_object(flow)
        end
          #column.map do { |flow| convert_flow_object(flow) }
      end
    end
  end

  def page(flow)
    page = service.find_page_by_uuid(flow.uuid)
    base_props(page).merge(
      url: page.url,
      next: flow.default_next
    )
  end

  def branch(flow)
    base_props(flow).merge(
      conditionals: branch_conditionals(
        flow.conditionals
      ).push(otherwise(flow.default_next))
    )
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
    flow_method_name = flow.type.gsub('flow.', '')
    send(flow_method_name, flow)
  rescue NoMethodError => e
    raise NotImplementedError,
          "'#{flow_method_name}' method not implemented for #{self}. Detail: #{e.message}"
  end

  def base_props(obj)
    {
      type: obj.type,
      title: obj.title,
      uuid: obj.uuid,
      previous_uuid: grid.previous_uuid_for_object(obj.uuid),
      previous_conditional_uuid: grid.conditional_uuid_for_object(obj.uuid),
      thumbnail: thumbnail_type(obj)
    }.compact
  end

  def thumbnail_type(obj)
    if use_flow_type?(obj)
      obj.type.gsub(/(flow|page)./, '')
    else
      obj.components.first.type
    end
  end

  def spacer(_)
    { type: 'spacer' }
  end

  def pointer(flow)
    {
      type: 'pointer',
      uuid: flow.uuid,
      title: flow_title(service.flow_object(flow.uuid))
    }
  end

  def warning(_)
    {
      type: 'warning',
      content: SubmissionPagesPresenter.new(service, I18n.t('warnings.pages_flow')).message
    }
  end

  def use_flow_type?(obj)
    obj.components.blank? ||
      obj.branch? ||
      %w[start checkanswers confirmation exit].any? { |type| obj.type.include?(type) }
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
      uuid: conditional.uuid,
      next: conditional.next,
      expressions: conditional_expressions(conditional)
    }
  end
  alias_method :and_conditional, :if_conditional

  def or_conditional(conditional)
    conditional.expressions.map do |expression|
      {
        uuid: conditional.uuid,
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
      operator: I18n.t("operators.#{expression.operator}"),
      answer: expression.field_label || ''
    }
  end

  def otherwise(default_next)
    {
      next: default_next,
      expressions: [
        {
          question: I18n.t('activemodel.attributes.branch.default_next'),
          operator: '',
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
