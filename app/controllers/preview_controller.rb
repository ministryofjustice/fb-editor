class PreviewController < PermissionsController
  layout 'presenter'
  self.per_form_csrf_tokens = false
end
