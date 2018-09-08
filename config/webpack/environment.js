const { environment } = require('@rails/webpacker');
const webpack = require('webpack');
const dotenv = require('dotenv');

const dotenvFiles = [
  `.env.${process.env.NODE_ENV}`,
  '.env'
];

dotenvFiles.forEach((dotenvFile) => {
  dotenv.config({ path: dotenvFile, silent: true })
});

environment.plugins.prepend('Environment', new webpack.EnvironmentPlugin(JSON.parse(JSON.stringify(process.env))));

environment.loaders.prepend('vue', {
  test: /\.vue$/,
  loader: 'vue-loader',
  options: {
    loaders: {
      js: 'babel-loader'
    }
  }
});

module.exports = environment;
