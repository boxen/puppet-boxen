require 'spec_helper'

# Stub out some boxen specific Facter facts
Facter.add('boxen_home') { setcode { '/opt/boxen' } }
Facter.add('luser') { setcode { 'skalnik' } }

describe 'boxen::bin' do
  let(:facts) do
    {
      :boxen__config__home => '/opt/boxen',
      :boxen_home          => '/opt/boxen'
    }
  end
  it { should contain_class('boxen::config') }
  it { should contain_file("#{facts[:boxen_home]}/bin/boxen") }
end
