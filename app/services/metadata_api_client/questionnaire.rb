module MetadataApiClient
  class Questionnaire < Resource
    def self.all_questionnaires(page: nil, per_page: nil)
      response = connection.get(
        '/questionnaires',
        {
          page:,
          per_page:
        }
      ).body

      {
        total_questionnaires: response['total_questionnaires'],
        questionnaires: Array(response['questionnaires']).map { |questionnaire| OpenStruct.new(questionnaire) }
      }
    end
  end
end
