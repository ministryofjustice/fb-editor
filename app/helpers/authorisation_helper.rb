module AuthorisationHelper
  def authorised_access
    return if moj_forms_admin? || moj_forms_dev?

    unless current_user.id == service.created_by
      redirect_to redirect_unauthorised_path
    end
  end

  def redirect_unauthorised_path
    return unauthorised_path unless preview?

    "#{request.base_url}/unauthorised"
  end

  def preview?
    URI(request.original_url).path.split('/').last == 'preview'
  end
end
