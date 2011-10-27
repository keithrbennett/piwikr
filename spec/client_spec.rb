require 'spec_helper'
require 'client'

module Piwikr

describe Client do

  it "should instantiate" do
    lambda { Client.new('http://www.example.com/piwik', 'abcdefghij', 1) }.should_not raise_error
  end

  it "should connect to Piwik and get a version number" do
    # Use of env. vars is for temporary convenience so as not to have to specify them in code or config.
    client = Client.new(ENV['PIWIK_URL'], ENV['PIWIK_TOKEN_AUTH'], 'all')
    version = client.piwik_version
    puts "version is {#{version}}"
    version.should_not be_nil
  end
end



end
