module OmniAuth::OpenIDConnect
  class Heroku < Provider
    def host
      config?('host') || "connect-op.heroku.com"
    end

    def client_options
      super.merge({
        :authorization_endpoint => "/authorizations/new",
        :token_endpoint => "/access_tokens",
        :userinfo_endpoint => "/user_info"
      })
    end
  end
end
