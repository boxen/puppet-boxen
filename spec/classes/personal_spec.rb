require 'spec_helper'

describe 'boxen::personal' do

  let(:username) { 'testuser' }
  let(:facts) { {
    :boxen_home => '/opt/boxen',
    :boxen_repodir => 'spec/fixtures',
    :github_login => username
  } }

  context "username with dash" do
    let(:username) { 'some-username' }

    it { should include_class('boxen::config')}
    it { should include_class('people::some_username')}
  end

  context 'dotfiles omitted' do
    it { should_not include_class('dotfiles')}
  end

  context 'dotfiles specified' do
    let(:params) { { :dotfiles => ['somethingrc'] } }

    it { should contain_dotfiles__symlink('somethingrc')}
  end

end
