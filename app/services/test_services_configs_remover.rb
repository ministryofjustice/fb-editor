class TestServicesConfigsRemover
  include MetadataVersionHelper

  def call
    models.each do |model|
      model.where.not(service_id: moj_forms_team_service_ids).in_batches.destroy_all
    end
  end

  private

  def models
    [ServiceConfiguration, SubmissionSetting, PublishService]
  end
end
