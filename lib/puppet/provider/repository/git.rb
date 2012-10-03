require 'fileutils'

Puppet::Type.type(:repository).provide(:git) do
  desc "Git repository clones"

  # FIX: needs to infer path
  CRED_HELPER = "-c credential.helper=/opt/boxen/bin/gh-setup-git-credential"
  GIT_BIN = "/opt/boxen/homebrew/bin/git"
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

    args = [
      GIT_BIN,
      "clone",
      CRED_HELPER,
      @resource[:extra].to_a.flatten.join(' ').strip,
      source,
      path
    ]

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
