class boxen::environment {
  require boxen::config
  require boxen::gemrc
  require boxen::janitor
  require boxen::profile
  require boxen::security
  include boxen::sudoers
}
