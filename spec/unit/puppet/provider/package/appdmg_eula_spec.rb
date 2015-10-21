#! /usr/bin/env ruby
require 'spec_helper'

describe Puppet::Type.type(:package).provider(:appdmg_eula) do
  let(:resource) { Puppet::Type.type(:package).new(:name => 'foo', :provider => :appdmg_eula) }
  let(:provider) { described_class.new(resource) }

  describe "when installing an appdmg with an eula" do

    let(:fake_mountpoint) { "/tmp/dmg.foo" }
    let(:empty_hdiutil_plist) { Plist::Emit.dump({}) }
    let(:fake_hdiutil_plist) { Plist::Emit.dump({"system-entities" => [{"mount-point" => fake_mountpoint}]}) }

    before do
      fh = double('filehandle')
      fh.stub(:path).and_return "/tmp/foo"
      resource[:source] = "foo.dmg"
      described_class.stub(:open).and_yield fh
      Dir.stub(:mktmpdir).and_return "/tmp/testtmp123"
      FileUtils.stub(:remove_entry_secure)
    end

    describe "from a remote source" do
      let(:tmpdir) { "/tmp/good123" }
      let(:source) { "http://fake.puppetlabs.com/foo.dmg" }

      before :each do
        resource[:source] = source
      end

      it "should call tmpdir and use the returned directory" do
        Dir.should_receive(:mktmpdir).and_return tmpdir
        Dir.stub(:entries).and_return ["foo.app"]
        described_class.should_receive(:curl).with('-o', "#{tmpdir}/foo", '-C', '-', '-L', '-s', '--url', source)
        described_class.should_receive(:hdiutil).with('convert', '/tmp/foo', '-format', 'UDTO', '-o', '/tmp/good123/appdmg_eula')
        described_class.should_receive(:hdiutil).with('attach', '-plist', '-nobrowse', '-readonly', '-noverify', '-noautoopen', '-mountrandom', '/tmp', "#{tmpdir}/appdmg_eula.cdr").and_return(fake_hdiutil_plist)
        described_class.should_receive(:installapp)
        described_class.should_receive(:hdiutil).with('eject', '/tmp/dmg.foo')

        provider.install
      end
    end
  end
end
