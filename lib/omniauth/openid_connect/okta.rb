module OmniAuth::OpenIDConnect
  class Okta < Provider
    def client_options
      opts = {
        :authorization_endpoint => "/oauth2/v1/authorize",
        :token_endpoint => "/oauth2/v1/token",
        :userinfo_endpoint => "/oauth2/v1/userinfo"
      }

      opts.merge super
    end
  end
end
