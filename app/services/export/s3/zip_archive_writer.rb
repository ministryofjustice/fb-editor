# frozen_string_literal: true

require 'json'
require 'zip'

module Export
  module S3
    # Streams version entries straight into a ZIP archive (no intermediate
    # JSON files on disk). Layout: <service_id>/<version_id>.json
    class ZipArchiveWriter
      class EmptyArchiveError < StandardError
        def initialize(msg = 'No version metadata files were generated')
          super
        end
      end

      def write(zip_path, services)
        count = 0

        Zip::File.open(zip_path, create: true) do |zip|
          services.each do |service|
            zip.get_output_stream(service_settings_path(service)) do |io|
              io.write(JSON.pretty_generate(service.settings.as_json(except: :id)))
            end
            service.versions.each do |version|
              zip.get_output_stream(service_matadata_path(service, version)) do |io|
                io.write(JSON.pretty_generate(version.metadata))
              end
            end
            count += 1
          end
        end

        raise EmptyArchiveError if count.zero?

        zip_path
      end

      private

      def service_settings_path(service)
        File.join(safe_name(service.service_id), 'settings.json')
      end

      def service_matadata_path(service, version)
        File.join(safe_name(service.service_id), "#{safe_name(version.version_id)}_#{Time.zone.parse(version.created_at).strftime('%Y%m%dT%H%M%SZ')}_metadata.json")
      end

      # Prevents IDs from introducing unexpected directory paths.
      def safe_name(value)
        value.to_s.gsub(/[^0-9A-Za-z._-]/, '_')
      end
    end
  end
end
