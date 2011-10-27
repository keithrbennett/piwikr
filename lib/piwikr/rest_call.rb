class RestCall

  attr_accessor :piwik_url, :website_spec, :api_method_name, :args

  def initialize(piwik_url, website_spec)
    @piwik_url = piwik_url
    @website_spec = website_spec
  end


  def call(api_method_name, args)
  end
end

