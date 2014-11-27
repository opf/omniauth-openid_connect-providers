require 'omniauth/openid_connect/providers/version'
require 'omniauth/openid_connect/provider'
require 'logger'

# load pre-defined providers
Dir[File.expand_path('../*.rb', __FILE__)].each do |file|
  require file
end

module OmniAuth
  module OpenIDConnect
    module Providers
      ##
      # Configures certain global provider settings. (optional)
      def self.configure(base_redirect_uri: nil, custom_options: [])
        Provider.base_redirect_uri = base_redirect_uri
        Provider.custom_option_keys = custom_options
      end

      ##
      # Given a configuration hash returns a list of configured providers.
      # The hash is expected to contain one entry for every provider.
      # Provider keys may specify a provider class to be used or omit this to use
      # the default class.
      #
      # Example:
      #
      # { :google => {...}, :test => {...}, 'google.plus' => {...} }
      #
      # =>
      #
      # [
      #   OmniAuth::OpenIDConnect::Google(name=google),
      #   OmniAuth::OpenIDConnect::Provider(name=test),
      #   OmniAuth::OpenIDConnect::Google(name=plus)
      # ]
      #
      # @param config [Hash] Hash containing the configuration for different providers.
      def self.load(config)
        providers = config.select do |key, cfg|
          provider, name = provider_class_and_name key.to_s

          provider.new cfg if provider
        end

        providers.compact
      end

      ##
      # For the given provider key within a configuration hash
      # this method returns both provider class and name.
      #
      # A provider class can be prepended to a provider name separated by a dot.
      # If a specific provider class can be associated it is returned.
      # Otherwise the default Provider class is used.
      #
      # Examples (with default provider Provider and specific provider Google):
      #
      # 'google'      => Google,   'google'
      # 'google.test' => Google,   'test'
      # 'random'      => Provider, 'random'
      def self.provider_class_and_name(provider_key)
        parts = provider_key.split('.')

        if parts.size == 2
          class_name = parts.first
          provider_name = parts.last
          provider_class = Provider.all.find { |cl| provider_name(cl.name) == class_name }

          [class_name, provider_name]
        else
          logger.warn "Skipping invalid provider key: #{provider_key}"

          []
        end
      end

      def self.provider_name(class_name)
        class_name.split('::').last.downcase
      end

      def self.logger
        @logger ||= Logger.new(STDOUT)
      end

      def self.logger=(logger)
        @logger = logger
      end
    end
  end
end
