class Nanoci
  class ToolError < StandardError
    attr_reader :cmd
    attr_reader :err
    attr_reader :code

    def initialize(cmd, err, code)
      msg = "command #{cmd} returned non-zero code #{code}: #{err}"
      super(msg)
      @cmd = cmd
      @err = err
      @code = code
    end
  end
end
