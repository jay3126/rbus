require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe "/blog" do
  before(:each) do
    @response = request("/blog")
  end
end