require 'spec_helper'

describe 'osx_defaults_for_team' do
  it { should include_class('osx_defaults::for_my_team') }
end

describe 'osx_defaults_for_team_member' do
  it { should include_class('osx_defaults::for_just_one_team_member') }
  it { should include_class('osx_defaults::for_my_team') }
end
