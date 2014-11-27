require 'omniauth/openid_connect/providers'

describe OmniAuth::OpenIDConnect::Provider do
  describe '#options alias #to_h' do
    describe 'redirect uri' do
      let(:config) do
        {
          port: 1234,
          scheme: 'ftp',
          host: 'example.net',
          identifier: 'chorizo',
          secret: 'fat'
        }
      end

      context 'without base redirect uri' do
        before do
          OmniAuth::OpenIDConnect::Providers.configure base_redirect_uri: nil
        end

        context 'with no specific configuration' do
          let(:provider) { OmniAuth::OpenIDConnect::Provider.new 'test', config }

          it 'throws an ArgumentError because of the missing redirect_uri' do
            expect{provider.to_h}.to raise_error(/configure redirect_uri/)
          end
        end

        context 'with a specific configuration' do
          let(:provider) do
            conf = config.merge redirect_uri: 'https://freelunch.com/oidc/test/callback'
            OmniAuth::OpenIDConnect::Provider.new 'test', conf
          end

          it 'does not fail due to a missing redirect uri' do
            expect{provider.to_h}.not_to raise_error
          end

          it 'is the configured uri' do
            expect(provider.to_h[:client_options][:redirect_uri]).to eq 'https://freelunch.com/oidc/test/callback'
          end
        end
      end

      context 'with base redirect_uri' do
        before do
          OmniAuth::OpenIDConnect::Providers.configure base_redirect_uri: 'https://umpalum.pa/'
        end

        let(:provider) { OmniAuth::OpenIDConnect::Provider.new 'test', config }

        it 'includes the correctly constructed callback URL' do
          expect{provider.to_h}.not_to raise_error
          expect(provider.to_h[:client_options][:redirect_uri]).to eq 'https://umpalum.pa/auth/test/callback'
        end
      end
    end

    describe 'base and custom options' do
      let(:config) do
        {
          port: 1234,
          scheme: 'ftp',
          host: 'example.net',
          identifier: 'chorizo',
          secret: 'fat',
          redirect_uri: 'https://example.net/auth/foo/callback'
        }
      end

      let(:provider) { OmniAuth::OpenIDConnect::Provider.new 'foo', config }

      before do
        OmniAuth::OpenIDConnect::Providers.configure custom_options: []
      end

      shared_examples 'base options' do
        it 'contain name, scope and client options' do
          opts = provider.to_h

          expect(opts[:name]).to eq 'foo'
          expect(opts[:scope]).to match_array [:openid, :email, :profile]
          expect(opts).to include :client_options
        end
      end

      context 'without custom options' do
        it_behaves_like 'base options'
      end

      context 'with custom options' do
        before do
          OmniAuth::OpenIDConnect::Providers.configure custom_options: [:icon?, :display_name]
        end

        context 'without configured display name' do
          it 'throws an ArgumentError due to the missing, required display name' do
            expect{provider.to_h}.to raise_error(/configure display_name/)
          end
        end

        context 'with configured display name' do
          before do
            config.merge! display_name: 'Prov1'
          end

          it_behaves_like 'base options'

          it 'contain display name' do
            expect(provider.to_h[:display_name]).to eq 'Prov1'
          end

          context 'without a configured icon' do
            it 'contains no icon' do
              expect(provider.to_h[:icon]).to be_nil
            end
          end

          context 'with a configured icon' do
            before do
              config.merge! icon: 'foobar.png'
            end

            it 'contains an icon' do
              expect(provider.to_h[:icon]).to eq 'foobar.png'
            end
          end
        end
      end
    end

    describe 'client options' do
      let(:config) do
        {
          port: 1234,
          scheme: 'ftp',
          host: 'example.net',
          identifier: 'chorizo',
          secret: 'fat',
        }
      end

      let(:provider) { OmniAuth::OpenIDConnect::Provider.new 'foo', config }

      before do
        OmniAuth::OpenIDConnect::Providers.configure base_redirect_uri: 'https://example.net', custom_options: []
      end
    end
  end
end
