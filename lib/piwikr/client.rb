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
      response, error = call('ExampleAPI.getPiwikVersion')
      error ? nil : Nokogiri::XML(response).xpath("/result").text
    end


    def visitor_log_summary(format, period, date = yyyymmdd(Time.now), filter_limit = 100)
      response, error = call('VisitsSummary.get', {
          #:format => format_string(format == :ruby ? :json : format),
          :format => format_string(format),
          :period => period_string(period),
          :date   => date,
          :filter_limit => filter_limit
      })
      error ? nil : response
    end

    # PDFReports.getReports (idSite = '', period = '', idReport = '', ifSuperUserReturnOnlySuperUserReports = '')
    # http://174.129.232.233/piwik/index.php?module=API&action=index&idSite=3&period=day&date=yesterday&updated=1&token_auth=c0e024d9200b5705bc4804722636378a&method=PDFReports.generateReport&idReport=1&outputType=1&language=en&reportFormat=pdf
    def get_reports(format, period, report_id, if_super_user_return_only_super_user_reports = false)
      response, error = call('PDFReports.getReports', {
          #:format => format_string(format == :ruby ? :json : format),
          :format => format_string(format),
          :period => period,
          :idReport => report_id,
          :ifSuperUserReturnOnlySuperUserReports => if_super_user_return_only_super_user_reports
      })
      error ? nil : response
    end

    # PDFReports.generateReport (idReport, date, idSite = '', language = '', outputType = '', period = '', reportFormat = '')
    def generate_report(report_id, output_filespec = 'report.pdf', date = yyyymmdd(Time.now))
      response, error = call('PDFReports.generateReport', {
          :idReport => report_id,
          :period => 'month',
          # :language = 'fr',
          :date => date
      })
      unless error
        File.open(output_filespec, 'wb') { |f| f << response }
      end
      error ? nil : response
    end
    

    def call(api_method_name, args = {})
      want_ruby_object = (args[:format] == 'ruby')
      args[:format] = :json if want_ruby_object
      params = rest_call_params(api_method_name, args)
      response = RestClient.get(piwik_url, params)
      error = error?(response)
      response = JSON.parse(response) if want_ruby_object && (! error)
      [response, error]
    end


    def format_string(symbol)
      format_strings = {
          :json => 'JSON',
          :xml  => 'XML',
          :csv  => 'CSV',
          :ruby => 'ruby'
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
      params = params.merge(args) if args

      # The params must be a key/value pair in a containing hash.
      { :params => params }
    end

# TODO: Error handling needs improvement.

    def error?(response)
      error_message = Nokogiri::XML(response).xpath('/result/error/@message').text
      error = ! error_message.empty?
      if error
        STDERR.puts "\nmessage: #{error_message}"
      end
      error
    end

    def yyyymmdd(time)
      time.strftime('%Y-%m-%d')
    end
  end
end

