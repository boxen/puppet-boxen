# Custom external facts loader, because you can't pass
# `--external-dir` to puppet.
#
# * Reads from $BOXEN_HOME/facts.d, instead of /etc/puppet/facts.d
# * Sets facts' weight to 1 higher than the default loader's weight

require 'facter/util/directory_loader'
require 'boxen/config'

class BoxenFactsDirectoryLoader < Facter::Util::DirectoryLoader
  EXTERNAL_FACT_WEIGHT = Facter::Util::DirectoryLoader::EXTERNAL_FACT_WEIGHT + 1
end

# Find where boxen is installed
config = Boxen::Config.load
boxen_home = config.repodir
facts_d = File.join(boxen_home, "facts.d")

# Load all "external facts" from $BOXEN_HOME/facts.d
loader = BoxenFactsDirectoryLoader.loader_for(facts_d)
loader.load(Facter.collection)
