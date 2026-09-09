class TransferOwnershipMailer < NotifyMailer
  def transfer_ownership(previous_owner:, new_owner:, service_name:)
    set_template(:transfer_ownership)

    set_personalisation(
      service_name:,
      previous_owner:
    )

    mail(to: new_owner)
  end

  def transfer_ownership_confirmation(previous_owner:, new_owner:, service_name:)
    set_template(:transfer_ownership_confirmation)

    set_personalisation(
      service_name:,
      new_owner:
    )

    mail(to: previous_owner)
  end
end
