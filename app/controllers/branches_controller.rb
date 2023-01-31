class BranchesController < FormController
  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder
  before_action :assign_branch, only: %i[new]

  def new; end

  def create
    @branch = Branch.new(branch_params)
    branch_creation = BranchCreation.new(
      branch: @branch,
      latest_metadata: service_metadata
    )

    if branch_creation.save
      redirect_to edit_branch_path(service.service_id, branch_creation.branch_uuid)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @branch = Branch.new(
      branch_metadata.merge(service: service, branch_uuid: params[:branch_uuid])
    )
  end

  def update
    @branch = Branch.new(branch_params)
    branch_updater = BranchUpdater.new(
      branch: @branch,
      latest_metadata: service_metadata
    )

    if branch_updater.save
      redirect_to edit_branch_path(service.service_id, params[:branch_uuid])
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def conditional_index
    params[:conditional_index] ? params[:conditional_index].to_i + 1 : nil
  end
  helper_method :conditional_index

  def destroy
    destination_uuid = params
      .require(:branch_destroyer)
      .permit(:destination_uuid)[:destination_uuid]

    @branch_destroyer = BranchDestroyer.new(
      service: service,
      branch_uuid: params[:branch_uuid],
      destination_uuid: destination_uuid,
      latest_metadata: service_metadata
    )
    @branch_destroyer.destroy

    redirect_to edit_service_path(service.service_id)
  end

  def branch_destinations
    @branch_destinations ||= @branch.main_destinations
  end

  def branch_detached_destinations
    @branch_detached_destinations ||= @branch.detached_destinations
  end

  helper_method :branch_destinations
  helper_method :branch_detached_destinations

  private

  def branch_metadata
    branch_object = service.flow_object(params[:branch_uuid])
    Branch.from_metadata(branch_object)
  end

  def assign_branch
    @branch = Branch.new(branch_attributes)
    @branch.conditionals << Conditional.new(expressions: [Expression.new])
  end

  def branch_attributes
    {
      service: service,
      previous_flow_uuid: previous_flow_uuid,
      branch_uuid: params[:branch_uuid]
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
