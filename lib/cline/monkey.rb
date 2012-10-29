require 'thor'

class Thor::Shell::Basic
  extend Forwardable

  def_delegators Cline, :stdio, :stderr
end
