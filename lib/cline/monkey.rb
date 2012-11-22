require 'thor'

class Thor::Shell::Basic
  extend Forwardable

  def_delegators Cline, :stdout, :stderr
end
