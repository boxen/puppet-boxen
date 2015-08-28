require 'spec_helper'
require 'boxen/autocomplete'

describe Boxen::Autocomplete do
  describe ".complete" do
    def call(string)
      Boxen::Autocomplete.complete(string)
    end

    let(:available_services) { ["mysql", "myother", "nginx"] }

    before do
      Boxen::Autocomplete.stub(:available_services).and_return(available_services)
    end

    it "completes from nothing" do
      call("boxen ").should include "-h"
    end

    it "completes from partial option" do
      call("boxen --res").should == ["--restart-service", "--restart-services"]
    end

    it "completes from end of service" do
      call("boxen --restart-service").should == ["--restart-service", "--restart-services"]
    end

    it "completes from after service" do
      call("boxen --restart-service ").should == available_services
    end

    it "completes from partial service name" do
      call("boxen --restart-service my").should == (available_services - ["nginx"])
    end

    it "completes from after service name" do
      call("boxen --restart-service nginx ").should include "-h"
    end

    it "completes files after file options" do
      call("boxen --logfile ").should be == []
      call("boxen --homedir ").should be == []
    end
  end
end
