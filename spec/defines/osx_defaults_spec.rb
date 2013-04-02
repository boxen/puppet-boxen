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
    should contain_exec("osx_defaults write  #{domain}:#{key}=>'#{value}'").
      with(:command => "/usr/bin/defaults write #{domain} #{key} '#{value}'")
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
        should contain_exec("osx_defaults write #{host} #{domain}:#{key}=>'#{value}'").
          with(:command => "/usr/bin/defaults -currentHost write #{domain} #{key} '#{value}'")
      end
    end

    context "specific host" do
      let(:host) { 'mybox.example.com' }

      it do
        should contain_exec("osx_defaults write #{host} #{domain}:#{key}=>'#{value}'").
          with(:command => "/usr/bin/defaults -host #{host} write #{domain} #{key} '#{value}'")
      end
    end
  end

  context "with hash value" do
    let(:params) do
      { :domain => domain,
        :key    => key,
        :type   => 'dict',
        :value  => { 'x' => 1 } # multiple values => unpredictable order so test may fail
      }
    end

    it do
      should contain_exec("osx_defaults write  #{domain}:#{key}=>'x' '1'").
        with(:command => "/usr/bin/defaults write #{domain} #{key} -dict 'x' '1'")
    end
  end

  context "value is array" do
    let(:params) do
      { :domain => domain,
        :key    => key,
        :type   => 'dict',
        :value  => [ 1, 2, 3, 4 ]
      }
    end

    it do
      should contain_exec("osx_defaults write  #{domain}:#{key}=>'1' '2' '3' '4'").
        with(:command => "/usr/bin/defaults write #{domain} #{key} -dict '1' '2' '3' '4'")
    end
  end
end
