#! /usr/bin/env ruby
require 'spec_helper'

describe Puppet::Type.type(:service).provider(:ghlaunchd) do
  let(:subject) {
    resource = Puppet::Type.type(:service).hash2resource({:name => 'some.vendor.service'})
    described_class.new(resource)
  }

  describe "start" do

    context "with some service plist" do

      it "should load a launch agent with sudo" do
        Dir.stubs(:glob).returns(['/Library/LaunchAgents/some.vendor.service.plist'])        
        Facter.stubs(:fact).with(:boxen_user).returns(stub(:value => 'some_user'))

        subject.stubs(:plutil).returns('{}')
        subject.stubs(:command).with(:launchctl).returns('/bin/launchctl')
        subject.expects(:sudo).with('-u', 'some_user', '/bin/launchctl', :load, '-w', '/Library/LaunchAgents/some.vendor.service.plist')
        subject.expects(:sudo).with('-u', 'some_user', '/bin/launchctl', :start, 'some.vendor.service')
        subject.start
      end

      it "should load but not start a inetd compatible launch agent" do
        Dir.stubs(:glob).returns(['/Library/LaunchAgents/some.vendor.service.plist'])        
        Facter.stubs(:fact).with(:boxen_user).returns(stub(:value => 'some_user'))

        subject.stubs(:plutil).returns('{}')
        subject.stubs(:command).with(:launchctl).returns('/bin/launchctl')
        subject.stubs(:config).returns({'inetdCompatibility' => {}})
        subject.expects(:sudo).with('-u', 'some_user', '/bin/launchctl', :load, '-w', '/Library/LaunchAgents/some.vendor.service.plist')
        subject.expects(:sudo).with('-u', 'some_user', '/bin/launchctl', :start, 'some.vendor.service').never()
        subject.start
      end  

      it "should load a launch deamon without sudo" do
        Dir.stubs(:glob).returns(['/Library/LaunchDeamons/some.vendor.service.plist'])

        subject.stubs(:plutil).returns('{}')
        subject.expects(:launchctl).with(:load, '-w', '/Library/LaunchDeamons/some.vendor.service.plist')
        subject.expects(:launchctl).with(:start, 'some.vendor.service')
        subject.start
      end
    end

    context "without some service plist" do
      Dir.stubs(:glob).returns([])

      it "should not load a launch agent" do
        Facter.stubs(:fact).with(:boxen_user).returns(stub(:value => 'some_user'))

        subject.stubs(:command).with(:launchctl).returns('/bin/launchctl')
        subject.expects(:sudo).with('-u', 'some_user', '/bin/launchctl', :load).never()
        subject.start.should be_false
      end

      it "should not load a launch deamon" do
        subject.expects(:launchctl).with(:load).never()
        subject.start.should be_false
      end
    end
  end

  describe "stop" do

    context "with some service plist" do
    
      it "should unload a launch agent" do
        Dir.stubs(:glob).returns(['/Library/LaunchAgents/some.vendor.service.plist'])
        Facter.stubs(:fact).with(:boxen_user).returns(stub(:value => 'some_user'))

        subject.stubs(:plutil).returns('{}')
        subject.stubs(:command).with(:launchctl).returns('/bin/launchctl')
        subject.expects(:sudo).with('-u', 'some_user', '/bin/launchctl', :unload, '-w','/Library/LaunchAgents/some.vendor.service.plist')
        subject.stop
      end

      it "should unload a launch deamon" do
        Dir.stubs(:glob).returns(['/Library/LaunchDeamons/some.vendor.service.plist'])        

        subject.stubs(:plutil).returns('{}')
        subject.expects(:launchctl).with(:unload, '-w', '/Library/LaunchDeamons/some.vendor.service.plist')
        subject.stop
      end
    end

    context "without some service plist" do
      Dir.stubs(:glob).returns([])

      it "should not unload a launch agent" do
        Facter.stubs(:fact).with(:boxen_user).returns(stub(:value => 'some_user'))

        subject.stubs(:command).with(:launchctl).returns('/bin/launchctl')
        subject.expects(:sudo).with('-u', 'some_user', '/bin/launchctl', :load).never()
        subject.stop.should be_false
      end

      it "should not unload a launch deamon" do
        subject.expects(:launchctl).with(:unload).never()
        subject.stop.should be_false
      end
    end
  end

end
