require 'spec_helper'

Facter.add('boxen_home') { setcode { '/opt/boxen' } }
Facter.add('luser') { setcode { 'skalnik' } }
Facter.add('boxen_repodir') do
  setcode do
    File.join(File.dirname(__FILE__), '..', 'fixtures')
  end
end

File.open(File.join(File.dirname(__FILE__), '..', 'fixtures', '.projects'), 'w+') do |f|
  f.truncate 0
  f.write 'test'
end

describe "boxen::environment" do
  context "projects from cli" do
    let(:facts) do
      {
        :boxen_home         => "/opt/boxen",
      }
    end

    it do
      should include_class("projects::test")
    end
  end
end
