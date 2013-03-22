# Public: Installed a zipped OS X widget

define boxen::zipped_widget(
                          $source,
                          $ensure = 'present'
                          ) {
  if $ensure == 'present' {
    $clean_source = strip($source)

    Exec {
      creates => "/Library/Widgets/${name}.wdgt"
    }

    exec {
      "zipped_widget-download-${name}":
        command => "/usr/bin/curl -L ${clean_source} > '/tmp/${name}.zip'",
        notify  => Exec["zipped_widget-extract-${name}"];
      "zipped_widget-extract-${name}":
        command     => "/usr/bin/unzip '/tmp/${name}.zip'",
        cwd         => '/Library/Widgets',
        user        => 'root',
        require     => Exec["zipped_widget-download-${name}"],
        refreshonly => true;
    }
  } else {
    if $name =~ /\.wdgt$/ {
      $wdgtname = $name
    } else {
      $wdgtname = "${name}.wdgt"
    }

    file { "/Library/Widgets/${wdgtname}":
      ensure => absent,
      force  => true
    }
  }
}
