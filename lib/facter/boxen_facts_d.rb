# Custom external facts loader, because you can't pass
# `--external-dir` to puppet.
#
# * Reads from $BOXEN_REPO_DIR/facts.d, instead of /etc/puppet/facts.d
# * Sets facts' weight to 1 higher than the default loader's weight

require 'facter/util/directory_loader'
require 'boxen/config'

class BoxenFactsDirectoryLoader < Facter::Util::DirectoryLoader
  EXTERNAL_FACT_WEIGHT = Facter::Util::DirectoryLoader::EXTERNAL_FACT_WEIGHT + 1

  def load(collection)
    entries.each do |file|
      parser = Facter::Util::Parser.parser_for(file)
      if parser == nil
        next
      end

      data = parser.results
      if data == false
        Facter.warn "Could not interpret fact file #{file}"
      elsif data == {} or data == nil
        Facter.warn "Fact file #{file} was parsed but returned an empty data set"
      else
        data.each { |p,v| collection.add(p, :value => v) { has_weight(EXTERNAL_FACT_WEIGHT) } }
      end
    end
  end
end

# Find where boxen is installed
config = Boxen::Config.load
facts_d = File.join(config.repodir, "facts.d")

# Load all "external facts" from $BOXEN_REPO_DIR/facts.d
loader = BoxenFactsDirectoryLoader.new(facts_d)
loader.load(Facter.collection)
