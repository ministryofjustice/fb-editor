/**
 * This is a wrapper class for Sentry Logging
 *
 * It will initialize Sentry with the correct DSN for the environment
 * injected by webpack.
 *
 * This module gets initialized and 'provided' by webpack to the whole
 * application.
 *
 * This means that anywhere in the code we can call SentryLogger.send() to
 * log an error to sentry.
 *
 * Errors will not be sent in the development environment
 *
 **/

const Sentry = require('@sentry/browser');

class SentryLogger {
  constructor(app) {
    Sentry.init({
      dsn: ''+app.sentry_dsn+'',
    });

    this.sentry = Sentry;
  }

  send(details) {
    if(app.platform_env != 'local') {
      if(typeof details == 'string') {
        this.sentry.captureMessage(details);
      } else {
        this.sentry.captureException(details);
      }
    }
  }
}

module.exports = SentryLogger
