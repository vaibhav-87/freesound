const path = require('path');

const rootPath = path.resolve('.');

const SUPPORTED_BROWSERS = [
  '>1%',
  'last 4 versions',
  'Firefox ESR',
  'not ie < 10',
];

module.exports = {
  entries: {
    index: path.join(__dirname, '..', 'src/index.js'),
  },
  output: {
    filename: '[name].js',
    path: path.join(__dirname, '..', 'dist'),
  },
  loaders: {
    jsLoader: {
      test: /\.js$/,
      exclude: /node_modules/,
      use: {
        loader: 'babel-loader',
        options: {
          presets: [
            [
              'env',
              {
                targets: {
                  browsers: SUPPORTED_BROWSERS,
                },
              },
            ],
          ],
        },
      },
    },
    postCssLoader: {
      loader: 'postcss-loader',
      options: {
        // Necessary for external CSS imports to work
        // https://github.com/facebookincubator/create-react-app/issues/2677
        ident: 'postcss',
        plugins: () => [
          require('postcss-flexbugs-fixes'),
          require('autoprefixer')({
            browsers: SUPPORTED_BROWSERS,
            flexbox: 'no-2009',
          }),
        ],
      },
    },
  },
};