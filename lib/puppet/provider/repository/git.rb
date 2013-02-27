require 'fileutils'
require 'shellwords'

Puppet::Type.type(:repository).provide(:git) do
  desc "Git repository clones"

  # FIX: needs to infer path
  CRED_HELPER_PATH = "#{Facter[:boxen_home].value}/bin/boxen-git-credential"
  CRED_HELPER = "-c credential.helper=#{CRED_HELPER_PATH}"
  GIT_BIN = "#{Facter[:boxen_home].value}/homebrew/bin/git"
  commands :git => GIT_BIN

  def self.default_protocol
    'https'
  end

  def exists?
    File.directory?(@resource[:path]) &&
      File.directory?("#{@resource[:path]}/.git")
  end

  def create
    source = expand_source(@resource[:source])
    path = @resource[:path]

    if File.exist? CRED_HELPER_PATH
      args = [
        GIT_BIN,
        "clone",
        CRED_HELPER,
        [@resource[:extra]].flatten.join(' ').strip,
        source,
        Shellwords.escape(path)
      ]
    else
      args = [
        GIT_BIN,
        "clone",
        [@resource[:extra]].flatten.join(' ').strip,
        source,
        Shellwords.escape(path)
      ]
    end

    execute args.flatten.join(' '), :uid => Facter[:luser].value
  end

  def destroy
    path = @resource[:path]

    FileUtils.rm_rf path
  end

  def expand_source(source)
    if source =~ /\A\S+\/\S+\z/
      "#{@resource[:protocol]}://github.com/#{source}"
    else
      source
    end
  end
end
