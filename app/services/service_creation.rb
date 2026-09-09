class ServiceCreation < Editor::Service
  def create
    return false if invalid?

    service = MetadataApiClient::Service.create(service_payload)

    if service.errors?
      add_errors(service)
      false
    else
      assign_service_attributes(service)
      DefaultConfiguration.new(self).create
      true
    end
  end

  def assign_service_attributes(service)
    tap do
      self.service_id = service.id
    end
  end

  def service_payload
    {
      metadata: NewServiceGenerator.new(
        service_name: service_name.strip,
        current_user:
      ).to_metadata,
      questionnaire: Questionnaire::AttributesExtractor.new(questionnaire).extract!
    }
  end
end
