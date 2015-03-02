# Private: Includes a user's personal configuration based on their GitHub username
#
# Usage:
#
#   include boxen::personal
#
# Parameters:
#
#   projects
#     Array of github projects to include
#   includes
#     Array of puppet modules to include
#   casks
#     Array of brew-casks to include (aliased as osx_apps)
#   homebrew_packages
#     Array of homebrew packages to install
#   custom_projects
#     Hash of custom project names and parameters

class boxen::personal (
  $projects          = [],
  $includes          = [],
  $casks             = [],
  $osx_apps          = undef,
  $homebrew_packages = [],
  $custom_projects   = {},
){
  include boxen::config

  $manifests = "${boxen::config::repodir}/modules/people/manifests"
  $login     = regsubst($boxen::config::login, '-','_', 'G')

  if $login != $boxen::config::login {
    notice("Changed boxen::personal login to ${login}")
  }
  if file_exists("${manifests}/${login}.pp") {
    include "people::${login}"
  }

  # If $projects looks like ['foo', 'bar'], behaves like:
  #   include projects::foo
  #   include projects::bar
  $project_classes = prefix($projects, 'projects::')
  ensure_resource('class', $project_classes)

  # If $includes looks like ['foo', 'bar'], behaves like:
  # class { 'foo': }
  # class { 'bar': }
  ensure_resource('class', $includes)

  # $casks and $osx_apps are synonyms. $osx_apps takes precedence
  $_casks = $osx_apps ? {
    undef   => $casks,
    default => $osx_apps
  }
  # If any casks/osx_apps are specified, declare them as brewcask packages
  if count($_casks) > 0 { include brewcask }
  ensure_resource('package', $_casks, {
    'provider'        => 'brewcask',
    'install_options' => ['--appdir=/Applications',
                          "--binarydir=${boxen::config::homebrewdir}/bin"],
  })

  # If any homebrew packages are specified , declare them
  ensure_resource('package', $homebrew_packages, {
    'provider' => 'homebrew',
  })

  # If any custom projects are specified, declare them.
  # e.g. $custom_projects = {
  #        'personal-site' => { 'ruby' => '2.1.2', 'nginx' => true }
  #      }
  # results in
  # boxen::project { 'personal-site':
  #   ruby  => '2.1.2',
  #   nginx => true,
  # }
  #
  # Multiple projects may be specified in the $custom_projects hash.
  create_resources(boxen::project, $custom_projects)
}
