# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self, :https
    policy.font_src    :self, :https, :data
    policy.img_src     :self, :https, :data
    policy.object_src  :none
    policy.script_src  :self,
                       "https://unpkg.com/alpinejs",
                       "https://cdn.jsdelivr.net/npm/marked@2.1.3/marked.min.js",
                       "https://www.googletagmanager.com/gtag/js"
    policy.style_src   :self,
                       :unsafe_inline
    policy.connect_src :self,
                       "*.sentry.io",
                       "*.google-analytics.com/*"

    # Specify URI for violation reports
    policy.report_uri "report-uri #{ENV['SENTRY_CSP_URL']}"
  end

  # Generate session nonces for permitted importmap and inline scripts
  config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
  config.content_security_policy_nonce_directives = %w(script-src)

  # Report violations without enforcing the policy.
  config.content_security_policy_report_only = false
end
