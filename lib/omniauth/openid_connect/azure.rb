module OmniAuth::OpenIDConnect
  class Azure < Provider
    def host
      config?(:host) || "login.microsoftonline.com"
    end

    def tenant
      config?(:tenant) || "common"
    end

    def icon
      config?(:icon) || "openid_connect/auth_provider-azure.png"
    end

    def use_graph_api
      config?(:use_graph_api) || false
    end

    def secret
      original_secret = super
      # Azure secret must be url-encoded, so let's check for any non-url safe characters.
      # If there are none, we assume the user has already taken care of url-encoding the secret.
      if original_secret =~ /[\/=\+]/
        CGI.escape(original_secret)
      else
        original_secret
      end
    end

    def client_options
      opts = {
        authorization_endpoint: "/#{tenant}/oauth2/authorize",
        token_endpoint: "/#{tenant}/oauth2/token",
        userinfo_endpoint: userinfo_endpoint
      }

      opts.merge(super).merge(:secret => secret)
    end

    def userinfo_endpoint
      if use_graph_api
        "https://graph.microsoft.com/oidc/userinfo"
      else
        "/#{tenant}/openid/userinfo"
      end
    end
  end
end
