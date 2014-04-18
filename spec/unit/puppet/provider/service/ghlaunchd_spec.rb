#! /usr/bin/env ruby
require 'spec_helper'

describe Puppet::Type.type(:service).provider(:ghlaunchd) do
  let(:subject) {
    resource = Puppet::Type.type(:service).hash2resource({:name => 'some.vendor.service'})
    described_class.new(resource)
  }
  let(:facts) {{
    :operatingsystem => 'darwin'
  }}

  Facter.add('boxen_user') { setcode { 'some_user' } }

  describe "start" do

    context "with some service plist" do

      it "should load a launch agent with sudo" do
        Dir.stub(:glob).and_return(['/Library/LaunchAgents/some.vendor.service.plist'])

        subject.stub(:plutil).and_return('{}')
        subject.stub(:command).with(:launchctl).and_return('/bin/launchctl')
        subject.should_receive(:sudo).with('-u', 'some_user', '/bin/launchctl', :load, '-w', '/Library/LaunchAgents/some.vendor.service.plist')
        subject.should_receive(:sudo).with('-u', 'some_user', '/bin/launchctl', :start, 'some.vendor.service')
        subject.start
      end

      it "should load but not start a inetd compatible launch agent" do
        Dir.stub(:glob).and_return(['/Library/LaunchAgents/some.vendor.service.plist'])

        subject.stub(:plutil).and_return('{}')
        subject.stub(:command).with(:launchctl).and_return('/bin/launchctl')
        subject.stub(:config).and_return({'inetdCompatibility' => {}})
        subject.should_receive(:sudo).with('-u', 'some_user', '/bin/launchctl', :load, '-w', '/Library/LaunchAgents/some.vendor.service.plist')
        subject.should_receive(:sudo).with('-u', 'some_user', '/bin/launchctl', :start, 'some.vendor.service').never
        subject.start
      end

      it "should load a launch deamon without sudo" do
        Dir.stub(:glob).and_return(['/Library/LaunchDeamons/some.vendor.service.plist'])

        subject.stub(:plutil).and_return('{}')
        subject.should_receive(:launchctl).with(:load, '-w', '/Library/LaunchDeamons/some.vendor.service.plist')
        subject.should_receive(:launchctl).with(:start, 'some.vendor.service')
        subject.start
      end
    end

    context "without some service plist" do

      it "should not load a launch agent" do
        Dir.stub(:glob).and_return([])

        subject.stub(:command).with(:launchctl).and_return('/bin/launchctl')
        subject.should_receive(:sudo).with('-u', 'some_user', '/bin/launchctl', :load).never
        subject.start.should be_false
      end

      it "should not load a launch deamon" do
        Dir.stub(:glob).and_return([])

        subject.should_receive(:launchctl).with(:load).never
        subject.start.should be_false
      end
    end
  end

  describe "stop" do

    context "with some service plist" do

      it "should unload a launch agent" do
        Dir.stub(:glob).and_return(['/Library/LaunchAgents/some.vendor.service.plist'])

        subject.stub(:plutil).and_return('{}')
        subject.stub(:command).with(:launchctl).and_return('/bin/launchctl')
        subject.should_receive(:sudo).with('-u', 'some_user', '/bin/launchctl', :unload, '-w', '/Library/LaunchAgents/some.vendor.service.plist')
        subject.stop
      end

      it "should unload a launch deamon" do
        Dir.stub(:glob).and_return(['/Library/LaunchDeamons/some.vendor.service.plist'])

        subject.stub(:plutil).and_return('{}')
        subject.should_receive(:launchctl).with(:unload, '-w', '/Library/LaunchDeamons/some.vendor.service.plist')
        subject.stop
      end
    end

    context "without some service plist" do

      it "should not unload a launch agent" do
        Dir.stub(:glob).and_return([])

        subject.stub(:command).with(:launchctl).and_return('/bin/launchctl')
        subject.should_receive(:sudo).with('-u', 'some_user', '/bin/launchctl', :load).never
        subject.stop.should be_false
      end

      it "should not unload a launch deamon" do
        Dir.stub(:glob).and_return([])

        subject.should_receive(:launchctl).with(:unload).never
        subject.stop.should be_false
      end
    end
  end

end
