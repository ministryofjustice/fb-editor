// config/webpack/base.js
const { webpackConfig, merge } = require("shakapacker")
const customConfig = {
  module: {
    rules: [
      {
        test: require.resolve("jquery"),
        loader: "expose-loader",
        options: {
          exposes: ["$", "jQuery"]
        }
      }
    ]
  }
}

module.exports = merge(webpackConfig, customConfig)


// Original environment.js now renamed to base.js
// const { environment } = require('@rails/webpacker')
// const webpack = require('webpack')

// environment.plugins.prepend('Provide',
//   new webpack.ProvidePlugin({
//     $: 'jquery',
//     jQuery: 'jquery',
//   })
// );

// // resolve-url-loader must be used before sass-loader
// environment.loaders.get('sass').use.splice(-1, 0, {
//   loader: 'resolve-url-loader'
// });

// // the folllwing is required to get sanitise-html to behave correctly as a
// // Common JS require under webpacker
// const nodeModulesLoader = environment.loaders.get('nodeModules')
// if (!Array.isArray(nodeModulesLoader.exclude)) {
//   nodeModulesLoader.exclude = (nodeModulesLoader.exclude == null)
//     ? []
//     : [nodeModulesLoader.exclude]
// }
// nodeModulesLoader.exclude.push(/sanitize-html/);

// const aliasConfig = {
//   'jquery': 'jquery/src/jquery',
//   'jquery-ui': 'jquery-ui-dist/jquery-ui.js',
// };
// environment.config.set('resolve.alias', aliasConfig);

// module.exports = environment
