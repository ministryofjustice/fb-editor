class BranchesController < FormController
  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

  def new
    @branch = Branch.new(branch_attributes)

    @branch.conditionals << Conditional.new(expressions: [OpenStruct.new])
  end

  def create
    @branch = Branch.new(branch_params)
    branch_creation = BranchCreation.new(@branch)

    if branch_creation.create
      redirect_to edit_branch_path(service.service_id, branch_creation.branch_uuid)
    else
      render :new
    end
  end

  def edit
    @branch = Branch.new(branch_attributes)
    # get all the questions and answers etc
    # render  edit.html.erb
  end

  def branch_attributes
    {
      service: service,
      previous_flow_uuid: params[:previous_flow_uuid] || params.require(:branch).permit(:previous_flow_uuid)
    }
  end

  def branch_params
    params.require(:branch).permit!.merge(branch_attributes)
#    {
#      service_id: service.service_id,
#      latest_metadata: service_metadata,
#      previous_flow_uuid: params[:branch][:flow_uuid],
  #  }.merge(params.require(:branch).permit!)
  end
end
