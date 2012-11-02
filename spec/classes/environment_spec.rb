require 'spec_helper'

describe "boxen::environment" do
  context "projects from cli" do
    let(:facts) do
      {
        :boxen_home         => "/opt/boxen",
        :boxen_repodir      => "spec/fixtures/repodir",
        :cli_boxen_projects => "example"
      }
    end

    it do
      should include_class("projects::example")
    end
  end
end