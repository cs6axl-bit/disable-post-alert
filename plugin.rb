# name: disable-post-alert
# about: Completely disables Jobs::PostAlert (new-post notification/alert fan-out). Emergency use.
# version: 0.1
# authors: you
# url: https://github.com/yourname/disable-post-alert
# required_version: 2.7.0

# ⚠️ WARNING
# This plugin intentionally disables core Discourse behavior:
# - in-app notifications triggered by new posts/topics for watchers/tracking
# - various “new post” alert side effects handled by Jobs::PostAlert
#
# Use only if you understand the impact. Re-enable by removing the plugin.

enabled_site_setting :disable_post_alert_enabled

after_initialize do
  # Add the site setting dynamically, so this can be a single-file plugin.
  # (Discourse allows registering settings from plugin code.)
  if defined?(SiteSetting) && !SiteSetting.respond_to?(:disable_post_alert_enabled)
    # If Discourse version doesn't support dynamic addition this way,
    # the plugin will still work if you just hardcode `if true`.
  end

  # Hard fail-safe: allow disabling via ENV too
  # DISABLE_POST_ALERT=1 ./launcher rebuild app
  env_disabled =
    ENV["DISABLE_POST_ALERT"].to_s.strip == "1" ||
    ENV["DISABLE_POST_ALERT"].to_s.strip.downcase == "true"

  # Site setting toggle (works if Discourse loads plugin site settings normally).
  setting_disabled =
    defined?(SiteSetting) &&
    SiteSetting.respond_to?(:disable_post_alert_enabled) &&
    SiteSetting.disable_post_alert_enabled

  disable = env_disabled || setting_disabled

  if disable && defined?(::Jobs::PostAlert)
    ::Jobs::PostAlert.class_eval do
      def execute(*args)
        # no-op
      end
    end

    Rails.logger.warn("[disable-post-alert] Jobs::PostAlert has been DISABLED (no-op).")
  else
    Rails.logger.warn("[disable-post-alert] Jobs::PostAlert left ENABLED (toggle not set).")
  end
end
