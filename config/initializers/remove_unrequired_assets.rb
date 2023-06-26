# Some gems add assets into the sprockets asset pipeline
# that are not needed or cause issues with compilation / compression. This
# monkeypatch allows us to remove them from the Sprockets paths
# 
# Add the mes of any gems whose assets you do not wish to be compiled 
# to the SKIP_GEMS constant.
module SprocketsPathsOverride
  SKIP_GEMS = ['govuk_publishing_components']

  def append_path(path)
    should_skip = SKIP_GEMS.any? do |gem|
      path.to_s.start_with?(Gem.loaded_specs[gem].full_gem_path)
    end
    super(path) unless should_skip
  end
end

Sprockets::Environment.prepend(SprocketsPathsOverride)
