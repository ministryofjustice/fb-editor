class PublisherMailer < NotifyMailer
  def first_time_publish_to_test(user:, form_name:, form_url:)
    set_template(:first_time_publish_to_test)

    set_personalisation(
      form_name:,
      form_url:
    )

    mail(to: user.email)
  end
end
