# name: disable-post-alert
# about: Emergency kill-switch: make Jobs::PostAlert a no-op to free Sidekiq threads.
# version: 0.1
# authors: you
# url: https://github.com/yourname/disable-post-alert

after_initialize do
  # Toggle via environment variable:
  #   DISABLE_POST_ALERT=1
  #
  # If you don't set it, the plugin does NOTHING.
  disable =
    ENV["DISABLE_POST_ALERT"].to_s.strip == "1" ||
    ENV["DISABLE_POST_ALERT"].to_s.strip.downcase == "true"

  unless disable
    Rails.logger.warn("[disable-post-alert] DISABLE_POST_ALERT not set; leaving Jobs::PostAlert enabled.")
    next
  end

  if defined?(::Jobs::PostAlert)
    ::Jobs::PostAlert.class_eval do
      def execute(*)
        # no-op intentionally
      end
    end

    Rails.logger.warn("[disable-post-alert] Jobs::PostAlert has been DISABLED (no-op).")
  else
    Rails.logger.warn("[disable-post-alert] Jobs::PostAlert constant not found; nothing patched.")
  end
end
