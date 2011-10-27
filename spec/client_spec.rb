require 'spec_helper'
require 'client'

module Piwikr

describe Client do

  let (:basic_client) do Client.new(ENV['PIWIK_URL'], ENV['PIWIK_TOKEN_AUTH'], 'all') end
  it "should instantiate" do
    lambda { Client.new('http://www.example.com/piwik', 'abcdefghij', 1) }.should_not raise_error
  end

  it "should connect to Piwik and get a version number" do
    # Use of env. vars is for temporary convenience so as not to have to specify them in code or config.
    #client = Client.new(ENV['PIWIK_URL'], ENV['PIWIK_TOKEN_AUTH'], 'all')
    version = basic_client.piwik_version
    version.should match /1\.6/
  end
end



end
