class NewMsListMailer < NotifyMailer
  def new_ms_list_created(user:, form_name:, list_name:, drive_name:)
    set_template(:new_ms_list_created)

    set_personalisation(
      form_name:,
      list_name:,
      drive_name:
    )

    mail(to: user.email)
  end
end
