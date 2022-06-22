class MetadataUrlValidator < ActiveModel::EachValidator
  include ApplicationHelper

  RESERVED = %w[
    admin
    dashboard
    health
    maintenance
    metrics
    ping
    reserved
    unauthorised
  ].freeze

  def validate_each(record, attribute, value)
    return if value.blank?

    clean_value = strip_url(value)

    urls = all_pages(record).map { |page| strip_url(page['url']) }
    if urls.include?(clean_value)
      record.errors.add(attribute, :taken)
    end

    if RESERVED.include?(clean_value)
      record.errors.add(attribute, :reserved)
    end
  end

  private

  def all_pages(record)
    metadata = record.send(options[:metadata_method])
    metadata['pages'] + metadata['standalone_pages']
  end
end
