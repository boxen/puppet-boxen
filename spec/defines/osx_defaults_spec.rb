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
    should contain_exec("osx_defaults write  #{domain}:#{key}=>#{value}").
      with(:command => "/usr/bin/defaults write #{domain} '#{key}' '#{value}'")
  end

  context 'with a key with spaces' do
    let(:key) { 'test key' }

    it 'quotes the key' do
      should contain_exec("osx_defaults write  #{domain}:#{key}=>#{value}").
        with(:command => "/usr/bin/defaults write #{domain} '#{key}' '#{value}'")
    end
  end

  context 'boolean handling' do
    let(:params) {
      { :domain => domain,
        :key    => key,
        :value  => value,
        :type   => 'boolean',
      }
    }

    context 'yes' do
      let(:value) { 'yes' }
      it 'converts yes to 1 for checking' do
        should contain_exec("osx_defaults write  #{domain}:#{key}=>#{value}").
          with(:unless => "/usr/bin/defaults read #{domain} '#{key}' && (/usr/bin/defaults read #{domain} '#{key}' | awk '{ exit $0 != \"1\" }')")
      end
    end

    context 'no' do
      let(:value) { 'no' }
      it 'converts no to 0 for checking' do
        should contain_exec("osx_defaults write  #{domain}:#{key}=>#{value}").
          with(:unless => "/usr/bin/defaults read #{domain} '#{key}' && (/usr/bin/defaults read #{domain} '#{key}' | awk '{ exit $0 != \"0\" }')")
      end
    end

    context 'true' do
      let(:value) { 'true' }
      it 'converts true to 1 for checking' do
        should contain_exec("osx_defaults write  #{domain}:#{key}=>#{value}").
          with(:unless => "/usr/bin/defaults read #{domain} '#{key}' && (/usr/bin/defaults read #{domain} '#{key}' | awk '{ exit $0 != \"1\" }')")
      end
    end

    context 'false' do
      let(:value) { 'false' }
      it 'converts false to 0 for checking' do
        should contain_exec("osx_defaults write  #{domain}:#{key}=>#{value}").
          with(:unless => "/usr/bin/defaults read #{domain} '#{key}' && (/usr/bin/defaults read #{domain} '#{key}' | awk '{ exit $0 != \"0\" }')")
      end
    end
  end

  context "with a boolean value" do
    let(:value) { true }
    let(:params) {
      { :domain => domain,
        :key    => key,
        :value  => value
      }
    }

    it do
      should contain_exec("osx_defaults write  #{domain}:#{key}=>#{value}").with(
        :command => "/usr/bin/defaults write #{domain} '#{key}' -bool '#{value}'"
      )
    end
  end

  context "with a host" do
    let(:params) {
      { :domain => domain,
        :key    => key,
        :value  => value,
        :host   => host
      }
    }

    context "currentHost" do
      let(:host) { 'currentHost' }

      it do
        should contain_exec("osx_defaults write #{host} #{domain}:#{key}=>#{value}").
          with(:command => "/usr/bin/defaults -currentHost write #{domain} '#{key}' '#{value}'")
      end
    end

    context "specific host" do
      let(:host) { 'mybox.example.com' }

      it do
        should contain_exec("osx_defaults write #{host} #{domain}:#{key}=>#{value}").
          with(:command => "/usr/bin/defaults -host #{host} write #{domain} '#{key}' '#{value}'")
      end
    end
  end
end
