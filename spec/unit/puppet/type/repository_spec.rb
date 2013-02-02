require 'spec_helper'

# Stub out some boxen specific Facter facts
Facter.add('boxen_home') { setcode { '/opt/boxen' } }
Facter.add('luser') { setcode { 'skalnik' } }

require 'puppet/type/repository'

describe Puppet::Type.type(:repository) do
  let(:resource) {
    described_class.new(:source => 'boxen/boxen', :path => '/tmp/boxen')
  }

  it "should accept an ensure property" do
    resource[:ensure] = :present
    resource[:ensure].should == :present
  end

  it "should accept an absolute path" do
    expect { resource[:path] = '/tmp/foo' }.to_not raise_error
  end

  it "should not accept a relative path" do
    expect {
      resource[:path] = 'foo'
    }.to raise_error(Puppet::Error, /Path is not an absolute path: foo/)
  end

  it "should accept a source parameter" do
    resource[:source] = 'boxen/test'
    resource[:source].should == 'boxen/test'
  end

  it "should accept a protocol parameter" do
    resource[:protocol] = 'git'
    resource[:protocol].should == 'git'
  end

  it "should accept an array of extra options" do
    resource[:extra] = ['foo', 'bar']
    resource[:extra].should == ['foo', 'bar']
  end

  it "should fail when not provided with a source" do
    expect {
      described_class.new(:path => '/tmp/foo')
    }.to raise_error(Puppet::Error, /You must specify a source/)
  end

  it "should fail when not provided with a path" do
    expect {
      described_class.new(:source => 'boxen/boxen')
    }.to raise_error(Puppet::Error, /Title or name must be provided/)
  end
end
