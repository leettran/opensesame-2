module OpenSesame
  class ConfigurationError < RuntimeError; end

  class Configuration
    CONFIGURABLE_ATTRIBUTES = [:organization_name, :mount_prefix, :github_client]
    attr_accessor *CONFIGURABLE_ATTRIBUTES

    def mounted_at(mount_prefix)
      self.mount_prefix = mount_prefix
    end

    def github(client_id, client_secret)
      self.github_client = { :id => client_id, :secret => client_secret }
    end

    def organization(organization_name)
      self.organization_name = organization_name
    end

    def configure
      yield self
    end

    def valid?
      self.organization_name && self.organization_name.is_a?(String) &&
      self.mount_prefix && self.mount_prefix.is_a?(String) &&
      self.github_client.is_a?(Hash) &&
      [:id, :secret].all? { |key| self.github_client.keys.include?(key) }
    end

    def validate!
      return true if valid?
      message = <<-MESSAGE


      Update your OpenSesame configuration. Example:

      # config/initializers/open_sesame.rb
      OpenSesame.configure do |config|
        config.organization 'challengepost'
        config.mounted_at   '/welcome'
        config.github       ENV['CAPITAN_GITHUB_KEY'], ENV['CAPITAN_GITHUB_SECRET']
      end

      When you register the app, make sure to point the callback url to
      the engine mountpoint + /auth/github/callback. For example, if your
      development app is on http://localhost:3000 and you're mounting
      the OpenSesame::Engine at '/welcome', your github
      callback url should be:

      http://localhost:3000/auth/github/callback

      MESSAGE

      raise ConfigurationError.new(message)
    end

  end
end