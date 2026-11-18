namespace :aws do
  namespace :s3 do
    desc 'Upload published services metadata and associations to S3'
    task upload_forms_metadata: :environment do
      Export::S3::Form::MetadataBackup.call(services_per_page: 20)
    end
  end
end
