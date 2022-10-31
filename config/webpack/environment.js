const { environment } = require('@rails/webpacker')
const webpack = require('webpack')
const path = require("path");

environment.plugins.prepend('Provide',
  new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery',
    SentryLogger: 'sentry-logger',
  })
);

environment.plugins.prepend('env',
  new webpack.DefinePlugin({
    'NODE_ENV': JSON.stringify(process.env.NODE_ENV),
    'SENTRY_DSN': (JSON.stringify(process.env.NODE_ENV) == 'production' ?  JSON.stringify('https://5c37dde874b24d8988f04157fade6015@o345774.ingest.sentry.io/5684540') : JSON.stringify('https://e7caecf8f1a54fbe99a50a4801237625@o345774.ingest.sentry.io/5671754')),
  })
);

// resolve-url-loader must be used before sass-loader
environment.loaders.get('sass').use.splice(-1, 0, {
  loader: 'resolve-url-loader'
});

// the folllwing is required to get sanitise-html to behave correctly as a
// Common JS require under webpacker
const nodeModulesLoader = environment.loaders.get('nodeModules')
if (!Array.isArray(nodeModulesLoader.exclude)) {
  nodeModulesLoader.exclude = (nodeModulesLoader.exclude == null)
    ? []
    : [nodeModulesLoader.exclude]
}
nodeModulesLoader.exclude.push(/sanitize-html/);

const aliasConfig = {
  'jquery': 'jquery/src/jquery',
  'jquery-ui': 'jquery-ui-dist/jquery-ui.js',
  'sentry-logger': path.resolve(__dirname, '../../app/javascript/src/sentry_logger'),
};
environment.config.set('resolve.alias', aliasConfig);

module.exports = environment
