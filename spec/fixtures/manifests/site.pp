node default {
  notify { 'test': }
}

#TODO: Remove this into whatever best practice is for specific fixtures
class osx_defaults::for_my_team {
  boxen::osx_defaults { 'Apply example default at team level':
    domain => 'com.example',
    key    => 'test',
    type   => boolean,
    value  => true
  }
}

class osx_defaults::for_just_one_team_member {
  boxen::osx_defaults {'Apply defaults for team member':
    domain => 'com.example',
    key    => 'test',
    type   => boolean,
    value  => true
  }
}

node osx_defaults_for_team {
  include osx_defaults::for_my_team
}

node osx_defaults_for_team_member {
  include osx_defaults::for_my_team
  include osx_defaults::for_just_one_team_member
}
