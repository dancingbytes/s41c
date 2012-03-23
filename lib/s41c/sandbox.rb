# encoding: utf-8

module S41C

  class Sandbox

    include S41C::Utils

    def initialize(ole, code)
      @ole = ole
      code.untaint
      @code = proc {
        $SAFE = 3
        instance_eval code, __FILE__, __LINE__
      }
    end

    def eval_code
      begin
        @code.call
      rescue WIN32OLERuntimeError => e
        "Error: #{to_utf8(e.message)}"
      rescue Exception => e
        "Error: #{e.message}"
      rescue => e
        "Error: #{e.message} from #{__FILE__}:#{__LINE__}"
      end
    end

  end

end # S41C
