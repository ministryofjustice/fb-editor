class ServiceDestroyer < Editor::Service
  def destroy(service_id)
    return false if invalid?

    service = MetadataApiClient::Service.destroy(service_id)

    if service.errors?
      add_errors(service)
      Rails.logger.debug(response.errors)
      false
    else
      NotificationService.notify(message)
      true
    end
  end

  private

  def message
    "#{service.service_name} has been deleted"
  end
end
