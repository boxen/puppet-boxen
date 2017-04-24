# Private: Includes a user's personal configuration based
#          on their GitHub username
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
  $merge_hierarchy = $boxen::config::hiera_merge_hierarchy

  if $login != $boxen::config::login {
    notice("Changed boxen::personal login to ${login}")
  }
  if file_exists("${manifests}/${login}.pp") {
    include "people::${login}"
  }

  # If $projects looks like ['foo', 'bar'], behaves like:
  #   include projects::foo
  #   include projects::bar
  $_projects = $merge_hierarchy ? {
    true      => hiera_array("${name}::projects",[]),
    default   => $projects
  }
  $project_classes = prefix($_projects, 'projects::')
  ensure_resource('class', $project_classes)

  # If $includes looks like ['foo', 'bar'], behaves like:
  # class { 'foo': }
  # class { 'bar': }
  $_includes = $merge_hierarchy ? {
    true      => hiera_array("${name}::includes",[]),
    default   => $includes
  }
  ensure_resource('class', $_includes)

  if $merge_hierarchy {
    $merged_osx_apps = hiera_array("${name}::osx_apps",undef)
    $merged_casks = hiera_array("${name}::casks",undef)

    $_casks = $merged_osx_apps ? {
      undef   => $merged_casks,
      default => $merged_osx_apps
    }
  }
  else {
    # $casks and $osx_apps are synonyms. $osx_apps takes precedence
    $_casks = $osx_apps ? {
      undef   => $casks,
      default => $osx_apps
    }
  }

  # If any casks/osx_apps are specified, declare them as brewcask packages
  if count($_casks) > 0 { include brewcask }
  ensure_resource('package', $_casks, {
    'provider'        => 'brewcask'
  })

  # If any homebrew packages are specified , declare them
  $_homebrew_packages = $merge_hierarchy ? {
    true      => hiera_array("${name}::homebrew_packages",[]),
    default   => $homebrew_packages
  }
  ensure_resource('package', $_homebrew_packages, {
    'ensure'   => 'latest',
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
  $_custom_projects = $merge_hierarchy ? {
    true      => hiera_array("${name}::custom_projects",{}),
    default   => $custom_projects
  }
  create_resources(boxen::project, $_custom_projects)
}
