#! /usr/bin/env ruby
require 'spec_helper'

describe Puppet::Type.type(:service).provider(:ghlaunchd) do
  let(:subject) {
    resource = Puppet::Type.type(:service).hash2resource({:name => 'some.vendor.service'})
    described_class.new(resource)
  }

  describe "start" do

    it "should start a launch agent with sudo" do
      Dir.stubs(:glob).returns(['/Library/LaunchAgents/some.vendor.service.plist'])
      Facter.stubs(:fact).with(:boxen_user).returns(stub(:value => 'some_user'))

      subject.stubs(:plutil).returns('{}')
      subject.stubs(:command).with(:launchctl).returns('/bin/launchctl')
      subject.expects(:sudo).with('-u', 'some_user', '/bin/launchctl', :load, '-w', '/Library/LaunchAgents/some.vendor.service.plist')
      subject.expects(:sudo).with('-u', 'some_user', '/bin/launchctl', :start, 'some.vendor.service')
      subject.start
    end

    it "should not start without a plist file" do
      Dir.stubs(:glob).returns([])

      subject.expects(:launchctl).never()
      subject.start.should == false
    end

    it "should start a launch deamon without sudo" do
      Dir.stubs(:glob).returns(['/Library/LaunchDeamons/some.vendor.service.plist'])

      subject.stubs(:plutil).returns('{}')
      subject.expects(:launchctl).with(:load, '-w', '/Library/LaunchDeamons/some.vendor.service.plist')
      subject.expects(:launchctl).with(:start, 'some.vendor.service')
      subject.start
    end
  end
end
