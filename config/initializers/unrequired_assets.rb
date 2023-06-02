module SprocketsPathsOverride
  SKIP_GEMS = ["govuk_publishing_components"]

  def append_path(path)
    should_skip = SKIP_GEMS.any? do |gem|
      path.to_s.start_with?(Gem.loaded_specs[gem].full_gem_path)
    end
    super(path) unless should_skip
  end
end

Sprockets::Environment.prepend(SprocketsPathsOverride)
