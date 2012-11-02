class boxen::environment {
  # must be run very early
  require boxen::config
  require boxen::gemrc

  # can be run whenever
  include boxen::bin
  include boxen::janitor
  include boxen::personal
  include boxen::profile
  include boxen::repo
  include boxen::security
  include boxen::sudoers

  include_projects_from_boxen_cli()
}