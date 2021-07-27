class BranchesController < FormController
  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder
  before_action :assign_branch, only: %i[new]

  def new; end

  def create
    @branch = Branch.new(branch_params)
    branch_creation = BranchCreation.new(branch: @branch, latest_metadata: service_metadata)

    if branch_creation.create
      redirect_to edit_branch_path(service.service_id, branch_creation.branch_uuid)
    else
      render :new
    end
  end

  def edit
    @branch = Branch.new(branch_attributes)
  end

  def conditional_index
    params[:conditional_index] ? params[:conditional_index].to_i + 1 : nil
  end
  helper_method :conditional_index

  private

  def assign_branch
    @branch = Branch.new(branch_attributes)
    @branch.conditionals << Conditional.new(expressions: [OpenStruct.new])
  end

  def branch_attributes
    {
      service: service,
      previous_flow_uuid: previous_flow_uuid
    }
  end

  def branch_params
    params.require(:branch).permit!.merge(branch_attributes)
  end

  def previous_flow_uuid
    params[:previous_flow_uuid] ||
      params[:branch_previous_flow_uuid] ||
      params.require(:branch).permit(:previous_flow_uuid)[:previous_flow_uuid]
  end
end
