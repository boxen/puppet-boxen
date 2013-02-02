require 'pathname'

Puppet.newtype(:repository) do
  @doc = "Clones or checks out a repository on a system"

  ensurable do
    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end

    defaultto :present
  end

  newparam(:path, :namevar => true) do
    desc "The path of the repository."

    validate do |value|
      unless Pathname.new(value).absolute?
        raise ArgumentError, "Path is not an absolute path: #{value}"
      end
    end
  end

  newparam(:source) do
    desc "The remote source for the repository."
  end

  newparam(:protocol) do
    desc "The protocol used to fetch the repository."

    defaultto do
      if provider.class.respond_to?(:default_protocol)
        provider.class.default_protocol
      end
    end
  end

  newparam(:extra, :array_matching => :all) do
    desc "Extra actions or information for a provider"
  end

  validate do
    if self[:source].nil?
      # ensure => absent does not need a source
      unless self[:ensure] == :absent || self[:ensure] == 'absent'
        self.fail "Repository[#{self[:name]}]: You must specify a source"
      end
    end
  end
end
