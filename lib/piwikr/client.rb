require 'rest-client'
require 'nokogiri'

module Piwikr

  class Client

    attr_accessor :piwik_url, :auth_token, :website_spec

    def initialize(piwik_url, auth_token, website_spec)
      @piwik_url = piwik_url
      @auth_token = auth_token
      @website_spec = website_spec
    end


    def call(api_method_name, args = nil)
      params = rest_call_params(api_method_name, args)
      RestClient.get(piwik_url, params)
    end


    def visitor_log()

    end


    def rest_call_params(api_method_name, args)
      params = {
          :token_auth => auth_token,
          :idSite     => website_spec,
          :module     => 'API',
          :method     => api_method_name
      }
      params.merge(args) if args

      # The params must be a key/value pair in a containing hash.
      { :params => params }
    end


    def piwik_version
      response = call('ExampleAPI.getPiwikVersion')
      Nokogiri::XML(response).xpath("/result").text
    end


  end
end

