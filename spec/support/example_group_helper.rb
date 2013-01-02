# coding: utf-8

module ExampleGroupHelper
  def capture(stream)
    begin
      stream = stream.to_s
      eval "$#{stream} = StringIO.new"
      yield
      result = eval("$#{stream}").string
    ensure
      eval("$#{stream} = #{stream.upcase}")
    end

    result
  end

  def wait_for_server(limit = 3)
    limit.times do
      sleep 2

      return if Cline::Server.running?
    end
  end
end
