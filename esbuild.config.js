require('esbuild').build({
  entryPoints: [
    'app/javascript/application.js',
    'app/javascript/govuk.js',
    'app/javascript/runner_application.js',
  ],
  bundle: true,
  sourcemap: true,
  watch: process.argv.includes("--watch"),
  outdir: 'app/assets/builds',
}).catch(() => process.exit(1))
