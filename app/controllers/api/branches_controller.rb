class Api::BranchesController < BranchesController
  before_action :assign_branch, only: %i[new_conditional]

  def new_conditional
    @child_index = params[:child_index]
    render partial: 'form_conditionals',
           locals: {
             f: default_form_builder.new(:branch, @branch, view_context, {})
           }
  end
end
