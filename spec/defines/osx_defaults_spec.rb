require 'spec_helper'

describe 'boxen::osx_defaults' do
  let(:title)  { 'example' }
  let(:domain) { 'com.example' }
  let(:key)    { 'testkey' }
  let(:value)  { 'yes' }

  let(:params) {
    { :domain => domain,
      :key    => key,
      :value  => value,
    }
  }

  it do
    should contain_exec("osx_defaults write  #{domain}:#{key}=>#{value}")
      .with(:command => "/usr/bin/defaults write #{domain} #{key} '#{value}'")
  end

  context "currentHost" do
    let(:host) { 'currentHost' }
    let(:params) {
      { :domain => domain,
        :key    => key,
        :value  => value,
        :host   => host
      }
    }

    it do
      should contain_exec("osx_defaults write #{host} #{domain}:#{key}=>#{value}")
        .with(:command => "/usr/bin/defaults -currentHost write #{domain} #{key} '#{value}'")
    end
  end
end
