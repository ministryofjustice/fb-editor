const { environment } = require('@rails/webpacker')
const webpack = require('webpack')

environment.plugins.prepend('Provide',
  new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery'
  })
);

// resolve-url-loader must be used before sass-loader
environment.loaders.get('sass').use.splice(-1, 0, {
  loader: 'resolve-url-loader'
});

const aliasConfig = { 'jquery': 'jquery/src/jquery', 'jquery-ui': 'jquery-ui-dist/jquery-ui.js' };
environment.config.set('resolve.alias', aliasConfig);

module.exports = environment
