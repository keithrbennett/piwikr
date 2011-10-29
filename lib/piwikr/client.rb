require 'rest-client'
require 'nokogiri'
require 'time'

module Piwikr

  class Client

    attr_accessor :piwik_url, :auth_token, :website_spec

    def initialize(piwik_url, auth_token, website_spec)
      @piwik_url = piwik_url
      @auth_token = auth_token
      @website_spec = website_spec
    end


    def piwik_version
      response = call('ExampleAPI.getPiwikVersion')
      error?(response)
      result = Nokogiri::XML(response).xpath("/result")
      result.text
    end


    def visitor_log(format, period, date = Time.now.strftime('%Y-%m-%d'), filter_limit = 100)
      response = call('VisitsSummary.get', {
          :format => format_string(format),
          :period => period_string(period),
          :date   => date,
          :filter_limit => filter_limit
      })
      error?(response) ? nil : response
    end


    def call(api_method_name, args = nil)
      params = rest_call_params(api_method_name, args)
      RestClient.get(piwik_url, params)
    end


    def format_string(symbol)
      format_strings = {
          :json => 'JSON',
          :xml  => 'XML',
          :csv  => 'CSV',
          # ...
      }
      format_strings.include?(symbol) ? format_strings[symbol] : nil
    end


    def period_string(symbol)
      period_strings = {
          :day   => 'day',
          :week  => 'week',
          :month => 'month',
          :year  => 'year',
          :range => 'range',
      }
      period_strings.include?(symbol) ? period_strings[symbol] : nil
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


    def error?(response)
      error_message = Nokogiri::XML(response).xpath('/result/error/@message')
      unless error_message.empty?
        STDERR.puts "\nmessage: #{error_message}"
      end
      error_message
    end
  end
end

