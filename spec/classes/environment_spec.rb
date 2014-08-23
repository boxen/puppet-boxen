require 'spec_helper'

Facter.add('boxen_home') { setcode { '/opt/boxen' } }
Facter.add('luser') { setcode { 'skalnik' } }
Facter.add('boxen_repodir') do
  setcode do
    File.join(File.dirname(__FILE__), '..', 'fixtures')
  end
end

describe "boxen::environment" do
  context "projects from cli" do
    let(:projects_file){ File.expand_path('../../fixtures/.projects', __FILE__) }
    let(:facts) do
      {
        :boxen_home              => "/opt/boxen",
        :boxen_repo_url_template => "https://github.com/%s"
      }
    end

    before do
      File.open(projects_file, 'w+') do |f|
        f.truncate 0
        f.write 'test'
      end
    end

    after do
      FileUtils.rm_f(projects_file)
    end

    it do
      should contain_class("projects::test")
    end
  end
end
