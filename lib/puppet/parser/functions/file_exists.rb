module Puppet::Parser::Functions
  newfunction(:file_exists, :type => :rvalue) do |args|
    unless args.length == 1
      raise Puppet::Error, "Must provide exactly one arg to file_exists"
    end

    File.exist? args[0]
  end
end
