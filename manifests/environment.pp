class boxen::environment {
  # must be run very early
  require boxen::config
  require boxen::gemrc

  # can be run whenever
  include boxen::janitor
  include boxen::profile
  include boxen::security
  include boxen::sudoers
}
