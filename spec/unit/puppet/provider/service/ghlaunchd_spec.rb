#! /usr/bin/env ruby
require 'spec_helper'

describe Puppet::Type.type(:service).provider(:ghlaunchd) do
  let(:subject) {
    resource = Puppet::Type.type(:service).hash2resource({:name => 'some.vendor.service'})
    described_class.new(resource)
  }

  describe "start" do

    it "should start a service with a plist file" do
      Dir.stubs(:glob).returns(['/Library/LaunchAgents/some.vendor.service.plist'])
        
      subject.stubs(:plutil).returns('{}')
      subject.expects(:launchctl).with(:load, '-w', '/Library/LaunchAgents/some.vendor.service.plist')
      subject.expects(:launchctl).with(:start, 'some.vendor.service')
      subject.start
    end

    it "should not start a service without a plist file" do
      Dir.stubs(:glob).returns([])

      subject.expects(:launchctl).never()
      subject.start.should == false
    end
  end
end
