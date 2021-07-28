class MetadataUrlValidator < ActiveModel::EachValidator
  include ApplicationHelper

  def validate_each(record, attribute, value)
    return if value.blank?

    urls = all_pages(record).map { |page| strip_url(page['url']) }
    if urls.include?(strip_url(value))
      record.errors.add(attribute, :taken)
    end
  end

  private

  def all_pages(record)
    metadata = record.send(options[:metadata_method])
    metadata['pages'] + metadata['standalone_pages']
  end
end
