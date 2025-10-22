const esbuild = require('esbuild');
let sentryPlugin;
try {
  // only require the plugin if it's installed and configured
  sentryPlugin = require('@sentry/esbuild-plugin');
} catch (e) {
  sentryPlugin = null;
}

const args = process.argv.slice(2);
const isWatch = args.includes('--watch');

const plugins = [];

if (sentryPlugin && process.env.SENTRY_AUTH_TOKEN && process.env.SENTRY_ORG && process.env.SENTRY_PROJECT && process.env.SENTRY_URL) {
  plugins.push(
    sentryPlugin({
      // plugin options here; esbuild plugin will upload sourcemaps if configured
      org: process.env.SENTRY_ORG,
      project: process.env.SENTRY_PROJECT,
      authToken: process.env.SENTRY_AUTH_TOKEN,
      url: process.env.SENTRY_URL
    })
  );
}

const buildOptions = {
  entryPoints: ['app/javascript/application.js'],
  bundle: true,
  sourcemap: true,
  format: 'esm',
  outdir: 'app/assets/builds',
  publicPath: '/assets',
  plugins
};

if (isWatch) {
  esbuild.build({
    ...buildOptions,
    watch: {
      onRebuild(error, result) {
        if (error) console.error('esbuild: rebuild failed:', error);
        else console.log('esbuild: rebuild succeeded');
      }
    }
  }).then(() => console.log('esbuild: watching...')).catch(() => process.exit(1));
} else {
  esbuild.build(buildOptions).then(() => console.log('esbuild: build complete')).catch(() => process.exit(1));
}
