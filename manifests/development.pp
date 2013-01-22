# Grab a ton of repositories related to Boxen itself and shove 'em in
# ${boxen::config::srcdir}/boxen. Include this class in your personal
# manifest if you're doing a lot of work on Boxen itself.

class boxen::development {
  require boxen::config

  $dir = "${boxen::config::srcdir}/boxen"

  file { $dir:
    ensure => directory
  }

  boxen::development::project {
    'boxen':;
    'boxen-web':;
    'boxen.github.com':;
    'cardboard':;
    'our-boxen':;
    'puppet-alfred':;
    'puppet-arq':;
    'puppet-augeas':;
    'puppet-autoconf':;
    'puppet-boxen':;
    'puppet-caffeine':;
    'puppet-chrome':;
    'puppet-clojure':;
    'puppet-colloquy':;
    'puppet-divvy':;
    'puppet-dnsmasq':;
    'puppet-dropbox':;
    'puppet-elasticsearch':;
    'puppet-emacs':;
    'puppet-erlang':;
    'puppet-fitbit':;
    'puppet-geoip':;
    'puppet-ghostscript':;
    'puppet-git':;
    'puppet-gitx':;
    'puppet-gpgme':;
    'puppet-graphviz':;
    'puppet-handbrake':;
    'puppet-heroku':;
    'puppet-homebrew':;
    'puppet-hub':;
    'puppet-icu4c':;
    'puppet-imagemagick':;
    'puppet-inifile':;
    'puppet-istatmenus3':;
    'puppet-iterm2':;
    'puppet-java':;
    'puppet-libtool':;
    'puppet-macvim':;
    'puppet-memcached':;
    'puppet-minecraft':;
    'puppet-mongodb':;
    'puppet-mysql':;
    'puppet-nginx':;
    'puppet-nodejs':;
    'puppet-notational_velocity':;
    'puppet-nvm':;
    'puppet-onepassword':;
    'puppet-osx':;
    'puppet-pcre':;
    'puppet-phantomjs':;
    'puppet-pkgconfig':;
    'puppet-postgresql':;
    'puppet-propane':;
    'puppet-python':;
    'puppet-qt':;
    'puppet-rbenv':;
    'puppet-rdio':;
    'puppet-redis':;
    'puppet-riak':;
    'puppet-ruby':;
    'puppet-sizeup':;
    'puppet-skype':;
    'puppet-solr':;
    'puppet-sparrow':;
    'puppet-spotify':;
    'puppet-sublime_text_2':;
    'puppet-sudo':;
    'puppet-swig':;
    'puppet-sysctl':;
    'puppet-template':;
    'puppet-textmate':;
    'puppet-things':;
    'puppet-virtualbox':;
    'puppet-viscosity':;
    'puppet-vlc':;
    'puppet-watts':;
    'puppet-wget':;
    'puppet-wkhtmltopdf':;
    'puppet-xquartz':;
    'puppet-zeromq':;
    'puppet-zsh':;
  }
}
