const merge = require('webpack-merge');
const environment = require('./environment');
const customConfig = require('./custom');

let config = environment.toWebpackConfig()
config.devtool = 'sourcemap';

module.exports = merge(config, customConfig);
