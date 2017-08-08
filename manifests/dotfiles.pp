# Private: Manage dotfiles.
#
# Usage:
#
#   boxen:dotfiles { 'dotfiles':
#     repository      => 'https://github.com/user/dotfiles',
#     local_directory => '.dotfiles',
#     install_command => 'install.sh'
#   }
#
# Parameters:
#
#   repository      - Git repository URL.
#   local_directory - Local location of where you would like to clone
#                     and manage the repository.
#   install_command - Script or inline command that you use to setup
#                     your repository.
define boxen::dotfiles(
  $repository      = undef,
  $local_directory = 'dotfiles',
  $install_command = undef,
) {
  require boxen::config

  $home = "/Users/${::boxen_user}"
  $dotfiles_dir = "${boxen::config::srcdir}/${local_directory}"

  repository { $dotfiles_dir:
    source => $repository,
  }

  if $install_command {
    exec { 'install dotfiles':
      cwd      => $dotfiles_dir,
      command  => $install_command,
      provider => shell,
      creates  => $dotfiles_dir,
      require  => Repository[$dotfiles_dir]
    }
  }
}
