// TODO - incorporate environment.js settings

process.env.NODE_ENV = process.env.NODE_ENV || 'development'
const mode = process.env.NODE_ENV === 'development' ? 'development' : 'production';
const environment = require('./environment.js.exclude')
const path = require("path")
const webpack = require("webpack")

// Extracts CSS into .css file
const MiniCssExtractPlugin = require('mini-css-extract-plugin');

// Removes exported JavaScript files from CSS-only entries
// in this example, entry.custom will create a corresponding empty custom.js file
const RemoveEmptyScriptsPlugin = require('webpack-remove-empty-scripts');

module.exports = {
  mode: "production",
  devtool: "source-map",
  entry: {
    application: [
      './app/javascript/application.js',
      './app/javascript/styles/application.scss'
    ]
  },
  output: {
    chunkFilename: "[name]-[contenthash].digested.js",
    filename: "[name].js",
    sourceMapFilename: "[file]-[fullhash].map",
    chunkFormat: "module",
    hashFunction: "sha256",
    hashDigestLength: 64,
    path: path.resolve(__dirname, '..', '..', 'app/assets/builds')
  },
  module: {
    rules: [
      {
        test: /\.(png|jpe?g|gif|eot|woff2|woff|ttf|svg)$/i,
        use: 'file-loader',
      },
      // Add CSS/SASS/SCSS rule with loaders
      {
        test: /\.(?:sa|sc|c)ss$/i,
        use: [MiniCssExtractPlugin.loader, 'css-loader', 'sass-loader'],
      },
    ],
  },
  resolve: {
    // Add additional file types
    extensions: ['.js', '.jsx', '.scss', '.css'],
  },
  plugins: [
    new webpack.optimize.LimitChunkCountPlugin({
      maxChunks: 1
    }),
    new RemoveEmptyScriptsPlugin(),
    new MiniCssExtractPlugin()
  ]
}
