require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'action_cable/engine'
require 'sprockets/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Syosset
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.active_job.queue_adapter = :resque

    # Don't generate system test files.
    config.generators.system_tests = nil

    # Load i18n files from subdirectories
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.yml')]

    # Paperclip storage configuration
    config.paperclip_defaults = {
      storage: :s3,
      s3_credentials: {
        bucket: ENV['S3_BUCKET_NAME'] || 'shs-uploads',
        access_key_id: ENV['AWS_ACCESS_KEY_ID'],
        secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
        s3_region: ENV['AWS_REGION'] || 'us-east-1'
      },
      s3_host_name: "s3-#{ENV['AWS_REGION'] || 'us-east-1'}.amazonaws.com",
      url: ENV['CDN_URL'].nil? ? ':s3_host_name' : ':s3_alias_url',
      path: '/:class/:attachment/:id_partition/:style/:filename',
      s3_host_alias: ENV['CDN_URL'],
      s3_protocol: :https
    }

    # Sentry configuration
    Raven.configure do |config|
      config.environments = %w[production staging]
      config.release = ENV['GIT_REV']
      config.silence_ready = true
    end

    config.time_zone = 'Eastern Time (US & Canada)'
  end
end
