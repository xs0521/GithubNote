/**
 * Build config for electron renderer process
 */

import path from 'path';
import webpack from 'webpack';
import HtmlWebpackPlugin from 'html-webpack-plugin';
import CspHtmlWebpackPlugin from 'csp-html-webpack-plugin';
import MiniCssExtractPlugin from 'mini-css-extract-plugin';
import { BundleAnalyzerPlugin } from 'webpack-bundle-analyzer';
import CssMinimizerPlugin from 'css-minimizer-webpack-plugin';
import { merge } from 'webpack-merge';
import TerserPlugin from 'terser-webpack-plugin';
import baseConfig from './webpack.config.base';
import webpackPaths from './webpack.paths';
import checkNodeEnv from '../scripts/check-node-env';
import deleteSourceMaps from '../scripts/delete-source-maps';

checkNodeEnv('production');
deleteSourceMaps();

const configuration: webpack.Configuration = {
  devtool: 'source-map',

  mode: 'production',

  target: ['web', 'electron-renderer'],

  entry: [path.join(webpackPaths.srcRendererPath, 'index.tsx')],

  output: {
    path: webpackPaths.distRendererPath,
    publicPath: './',
    filename: 'renderer.js',
    library: {
      type: 'umd',
    },
  },

  module: {
    rules: [
      {
        test: /\.s?(a|c)ss$/,
        use: [
          MiniCssExtractPlugin.loader,
          {
            loader: 'css-loader',
            options: {
              modules: true,
              sourceMap: true,
              importLoaders: 2,
            },
          },
          'postcss-loader',
          'sass-loader',
        ],
        include: /\.module\.s?(c|a)ss$/,
      },
      {
        test: /\.s?(a|c)ss$/,
        use: [
          MiniCssExtractPlugin.loader,
          'css-loader',
          'postcss-loader',
          'sass-loader',
        ],
        exclude: [/\.module\.s?(c|a)ss$/, /node_modules/],
      },
      // node_modules CSS — skip postcss/Tailwind to preserve third-party styles
      // sideEffects: true overrides @milkdown/crepe's "sideEffects": false so
      // webpack does not tree-shake CSS-only imports (which have no JS exports).
      {
        test: /\.css$/,
        sideEffects: true,
        use: [MiniCssExtractPlugin.loader, 'css-loader'],
        include: /node_modules/,
      },
      // Fonts
      {
        test: /\.(woff|woff2|eot|ttf|otf)$/i,
        type: 'asset/resource',
      },
      // Images
      {
        test: /\.(png|jpg|jpeg|gif)$/i,
        type: 'asset/resource',
      },
      // SVG
      {
        test: /\.svg$/,
        use: [
          {
            loader: '@svgr/webpack',
            options: {
              prettier: false,
              svgo: false,
              svgoConfig: {
                plugins: [{ removeViewBox: false }],
              },
              titleProp: true,
              ref: true,
            },
          },
          'file-loader',
        ],
      },
    ],
  },

  optimization: {
    minimize: true,
    minimizer: [new TerserPlugin(), new CssMinimizerPlugin()],
  },

  plugins: [
    /**
     * Create global constants which can be configured at compile time.
     *
     * Useful for allowing different behaviour between development builds and
     * release builds
     *
     * NODE_ENV should be production so that modules do not perform certain
     * development checks
     */
    new webpack.EnvironmentPlugin({
      NODE_ENV: 'production',
      DEBUG_PROD: false,
    }),

    new MiniCssExtractPlugin({
      filename: 'style.css',
    }),

    new BundleAnalyzerPlugin({
      analyzerMode: process.env.ANALYZE === 'true' ? 'server' : 'disabled',
      analyzerPort: 8889,
    }),

    new HtmlWebpackPlugin({
      filename: 'index.html',
      template: path.join(webpackPaths.srcRendererPath, 'index.ejs'),
      minify: {
        collapseWhitespace: true,
        removeAttributeQuotes: true,
        removeComments: true,
      },
      isBrowser: false,
      isDevelopment: false,
    }),

    new CspHtmlWebpackPlugin(
      {
        'base-uri': "'self'",
        'object-src': "'none'",
        'script-src': [
          "'self'",
          "'unsafe-inline'",
          "'unsafe-eval'",
          'https://unpkg.com',
          'https://api.github.com',
          'https://github.com',
          'https://cdn.jsdelivr.net',
        ],
        'style-src': [
          "'self'",
          "'unsafe-inline'",
          'https://unpkg.com',
          'https://api.github.com',
          'https://github.com',
          'https://fonts.googleapis.com',
          'https://fonts.gstatic.com',
          'https://cdn.jsdelivr.net',
        ],
        'frame-src': "'none'",
        'worker-src': "'none'",
        'img-src': ["'self'", 'data:', 'https:'],
        'font-src': [
          "'self'",
          'data:',
          'https://unpkg.com',
          'https://fonts.googleapis.com',
          'https://fonts.gstatic.com',
          'https://cdn.jsdelivr.net',
        ],
        'connect-src': [
          "'self'",
          'https://unpkg.com',
          'https://api.github.com',
          'https://github.com',
          'https://fonts.googleapis.com',
          'https://fonts.gstatic.com',
          'https://cdn.jsdelivr.net',
        ],
      },
      {
        nonceEnabled: {
          'script-src': false,
          'style-src': false,
        },
      },
    ),

    new webpack.DefinePlugin({
      'process.type': '"renderer"',
    }),
  ],
};

export default merge(baseConfig, configuration);
