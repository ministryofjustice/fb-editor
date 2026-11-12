# frozen_string_literal: true

require 'json'
require 'zip'

module Export
  module S3::Form
    # Streams version entries straight into a ZIP archive (no intermediate
    # JSON files on disk). Layout: <service_id>/<version_id>.json
    class ZipArchiveWriter
      class EmptyArchiveError < StandardError
        def initialize(msg = 'No version metadata files were generated')
          super
        end
      end

      UNSAFE_CHARACTERS = /[^0-9A-Za-z._-]/
      TIMESTAMP_FORMAT  = '%Y%m%dT%H%M%S'

      def write(zip_path, services)
        count = 0

        Zip::File.open(zip_path, create: true) do |zip|
          services.each do |service|
            zip.get_output_stream(file_path(service, 'service.json')) do |io|
              io.write(JSON.pretty_generate({ service_id: service.service_id, service_name: service.service_name }))
            end

            if service.settings.present?
              zip.get_output_stream(file_path(service, 'settings.json')) do |io|
                io.write(JSON.pretty_generate(service.settings.as_json(except: :id)))
              end
            end

            if service.items.present?
              zip.get_output_stream(file_path(service, 'items.json')) do |io|
                io.write(JSON.pretty_generate(service.items.as_json(except: :id)))
              end
            end

            if service.versions.present?
              service.versions.each do |version|
                zip.get_output_stream(file_path(service, version_filename(version))) do |io|
                  io.write(JSON.pretty_generate(version.metadata))
                end
              end
            end

            count += 1
          end
        end

        raise EmptyArchiveError if count.zero?

        zip_path
      end

      private

      def file_path(service, file_name)
        File.join(safe_name(service.service_id), file_name)
      end

      def version_filename(version)
        timestamp = Time.zone.parse(version.created_at).strftime(TIMESTAMP_FORMAT)
        "version_#{timestamp}_#{safe_name(version.locale)}_#{safe_name(version.version_id)}.json"
      end

      # Prevents IDs from introducing unexpected directory paths.
      def safe_name(value)
        value.to_s.gsub(UNSAFE_CHARACTERS, '_')
      end
    end
  end
end
