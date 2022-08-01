# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )


# The values for this are either :sass or :yui
# If we use :sass then we get syntax errors, as it reads css as sass, and fails
# on max() syntax
# If we use :yui, we need java in the pipeline
# So for now we can set nil, and set dart-sass called by yarn to compressed
# mode.
Rails.application.config.assets.css_compressor = nil
