require 'spec_helper'

describe 'boxen::personal' do
  
  context "username with dash" do
    let(:facts) do
      {
        :boxen_home => '/opt/boxen',
        :boxen_repodir => 'spec/fixtures',
        :github_login => 'some-username',
      }
    end

    it { should include_class('boxen::config')}
    it { should include_class('people::some_username')}
  end
end
