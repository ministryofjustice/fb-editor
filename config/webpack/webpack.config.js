// See the shakacode/shakapacker README and docs directory for advice on customizing your webpackConfig.
const { generateWebpackConfig } = require('shakapacker')

const webpackConfig = generateWebpackConfig({
  resolve: {
    alias: {
      jquery: 'jquery/src/jquery',
      'jquery-ui': 'jquery-ui-dist/jquery-ui.js',
    },
  },
})

module.exports = webpackConfig
