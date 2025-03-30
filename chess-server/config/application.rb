require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ChessServer
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    # config.api_only = true
    config.autoload_paths += [config.root.join('app/models/objects')]
    config.autoload_paths += [config.root.join('app/models/objects/pieces')]

    if Rails.env.production?
      engine_interface_hostname = "chess-engine-interface"
      engine_interface_port = 10000
    else
      engine_interface_hostname = "127.0.0.1"
      engine_interface_port = 5000
    end
  end
end

Rails.autoloaders.main.ignore(Rails.root.join('app/models/objects'))