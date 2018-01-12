require "stringio"
def capture_stderr
  real_stderr, $stderr = $stderr, StringIO.new
  yield
  $stderr.string
ensure
  $stderr = real_stderr
end
