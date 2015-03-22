# Boxen

[![Build Status](https://travis-ci.org/boxen/puppet-boxen.svg?branch=master)](https://travis-ci.org/boxen/puppet-boxen)

The Boxen puppet module for... Boxen.

# Required Modules for Boxen

Fundamental modules and types used by all of Boxen.

## Usage

```puppet
# We owe you examples. Sorry.
```

## Facts

Boxen loads facts from following locations:

 - `~/.boxen/config.json` (weight `-1`)
 - `$BOXEN_HOME/config/facts/*.json` (weight `-1`)
 - `$BOXEN_REPO_DIR/facts.d/` (weight [`EXTERNAL_FACT_WEIGHT + 1` = `10001`](https://github.com/puppetlabs/facter/blob/181c861f4ccc0919ecf3c58ee56fd9ed58930f95/lib/facter/util/directory_loader.rb#L31)) - various filetypes, see [documentation](https://docs.puppetlabs.com/facter/2.4/custom_facts.html#external-facts)
 - `_MODULEPATH_/_MODULE-NAME_/lib/facter/*.rb` (weight set by vendor or [default = number of `confines`](https://github.com/puppetlabs/facter/blob/beb4eb155c1b12346d8f3c7500fd335815a1a17d/lib/facter/core/suitable.rb#L103), no confines = `0`)

Facter itself also loads facts from environment variables with mask `FACTER_*` (weight [`1_000_000`](https://github.com/puppetlabs/facter/blob/beb4eb155c1b12346d8f3c7500fd335815a1a17d/lib/facter/util/loader.rb#L147)).

Default values:
 - [`_MODULEPATH_=$BOXEN_REPO_DIR/shared`](https://github.com/boxen/boxen/blob/242ff15da7a4822312fc18697e252dd756334b64/lib/boxen/puppeteer.rb#L105)
 - [`$BOXEN_REPO_DIR=Dir.pwd`](https://github.com/boxen/boxen/blob/535f66582e7f72ee070e48456081c9fbd22463ae/lib/boxen/config.rb#L220) - de facto root of this repository, typically cloned into `/opt/boxen/repo`

## Configuration

 - `ENV['BOXEN_HOME']/config/boxen/defaults.json`
   - Default [`$BOXEN_HOME = /opt/boxen`](https://github.com/boxen/boxen/blob/535f66582e7f72ee070e48456081c9fbd22463ae/lib/boxen/config.rb#L125)

## Development

Write code. Run `script/cibuild` to test it. Check the `script`
directory for other useful tools.
