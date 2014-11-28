module OmniAuth
  module OpenIDConnect
    ##
    # A Provider allows the configuration of OpenIDConnect a provider based on
    # a simplified, flat hash.
    #
    # To get the final OmniAuth provider option hash simply use #to_h.
    class Provider
      attr_reader :name, :configuration

      ##
      # Creates a new provider instance used to configure an OmniAuth provider for
      # the OpenIDConnect strategy.
      #
      # @param name [String] Provider name making it available under
      #                      /auth/<name>/callback by default.
      # @param config [Hash] Hash containing the configuration for this provider as a flat hash.
      def initialize(name, config)
        @name = name
        @configuration = symbolize_keys config
      end

      def to_h
        options
      end

      def options
        opts = {
          name:           name,
          scope:          scope,
          client_options: client_options
        }

        opts.merge(custom_options)
      end

      def required_client_options
        {
          port:         443,
          scheme:       'https',
          host:         host,
          identifier:   identifier,
          secret:       secret,
          redirect_uri: redirect_uri
        }
      end

      def custom_options
        entries = Providers.custom_option_keys.map do |key|
          name, optional = key.to_s.scan(/^([^\?]+)(\?)?$/).first
          name = name.to_sym
          value = optional ? config?(name) : config(name)

          [name, value]
        end

        Hash[entries]
      end

      def self.all
        @providers ||= Set.new
      end

      def self.inherited(subclass)
        all << subclass
      end

      def client_options
        # keys excluded either because they are already configured or
        # because they are not client options
        excluded_keys = [:identifier, :secret, :redirect_uri, :host] + custom_options.keys
        entries = configuration
          .reject { |key, value| excluded_keys.include? key.to_sym }
          .map { |key, value| [key.to_sym, value] }

        required_client_options.merge(Hash[entries]) # override with configuration
      end

      def host
        config?(:host) || host_from_endpoint || error_configure(:host)
      end

      def identifier
        config :identifier
      end

      def secret
        config :secret
      end

      def scope
        config?(:scope) || [:openid, :email, :profile]
      end

      ##
      # Path to which to redirect after successful authentication with the provider.
      def redirect_path
        "/auth/#{name}/callback"
      end

      def redirect_uri
        config?(:redirect_uri) || default_redirect_uri || error_configure(:redirect_uri)
      end

      def default_redirect_uri
        base = Providers.base_redirect_uri

        base.gsub(/\/$/, '') + redirect_path if base
      end

      private

      def error_configure(name)
        msg = <<-MSG
              Please configure #{name} in the given configuration hash like this:

              #{provider_class_name}.#{self.name}:
                #{name}: <value>
        MSG
        raise ArgumentError, "#{msg.strip}\n"
      end

      def provider_class_name
        Providers.provider_name self.class.name
      end

      ##
      # Returns the configuration value for the given key or nil if it doesn't exist.
      def config?(key)
        self.configuration[key]
      end

      ##
      # Returns the configuration value for the given key or
      # raises an exception if it doesn't exist.
      def config(key)
        configuration[key] || error_configure(key)
      end

      def host_from_endpoint
        begin
          URI.parse(config?(:authorization_endpoint)).host
        rescue URI::InvalidURIError
          nil
        end
      end

      def symbolize_keys(hash)
        entries = hash.map { |key, value| [key.to_s.to_sym, value] }
        Hash[entries]
      end
    end
  end
end
