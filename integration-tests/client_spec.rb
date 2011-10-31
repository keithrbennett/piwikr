require File.join(File.dirname(__FILE__), 'spec_helper')
require 'client'
require 'json'
require 'pp'

module Piwikr

# This is really an integration test and not a unit test.
# It assumes certain setup, such as a Piwik site and authorization token
# being in environment variables, and that the web site at site id 3
# is visible to the user who is the owner of the auth. token.

describe Client do

  # Use of env. vars is for temporary convenience so as not to have to specify them in code or config.
  let (:basic_client) do Client.new(ENV['PIWIK_URL'], ENV['PIWIK_TOKEN_AUTH'], 3) end
  
  it "should instantiate" do
    lambda { Client.new('http://www.example.com/piwik', 'abcdefghij', 1) }.should_not raise_error
  end

  it "should connect to Piwik and get a version number" do
    version = basic_client.piwik_version
    version.should match /^1\.6/
    puts "Piwik version is #{version}."
  end

  it "should get a visitor log" do
    response = basic_client.visitor_log_summary(:ruby, :year)
    response.should_not be_nil
    puts "Visitor summary info is: #{response.inspect}"
  end

  # !!! Assumes that a report #3 exists and is accessible to this user.
  it "should get reports" do
    response = basic_client.get_reports(:ruby, 3)
    #puts "\n\n\n#{response.pretty_inspect}\n\n\n"
    response.should_not be_nil
  end

  # !!! Assumes that a report #3 exists and is accessible to this user.
  it "should generate a report" do
    response = basic_client.generate_report(3)
    response.should_not be_nil
  end

end



end
