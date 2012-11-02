require 'spec_helper'

Facter.add('boxen_home') { setcode { '/opt/boxen' } }
Facter.add('luser') { setcode { 'skalnik' } }
Facter.add('cli_boxen_projects') { setcode { 'test' } }
Facter.add('boxen_repodir') do
  setcode do
    File.join(File.dirname(__FILE__), '..', 'fixtures')
  end
end

describe "boxen::environment" do
  context "projects from cli" do
    let(:facts) do
      {
        :boxen_home         => "/opt/boxen",
        :boxen_repodir      => "spec/fixtures",
        :cli_boxen_projects => "test"
      }
    end

    it do
      should include_class("projects::test")
    end
  end
end