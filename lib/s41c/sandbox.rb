# encoding: utf-8

module S41C #:nodoc

  class Sandbox #:nodoc

    include S41C::Utils

    #:nodoc
    def initialize(ole, local_storage, dump)
      @ole = ole
      @local_storage = local_storage

      dump.untaint
      hsh = Marshal.load(dump.unpack('m')[0])

      @vars = hsh[:vars]
      @vars.each do |key, value|
        self.instance_variable_set(:"@#{key}", value)
      end

      @code = proc {
        $SAFE = 3
        instance_eval hsh[:code], __FILE__, __LINE__
      }
    end

    #:nodoc
    def eval_code
      begin
        @code.call
      rescue WIN32OLERuntimeError => e
        "Error: #{to_utf8(e.message)}"
      rescue Exception => e
        "Error Exception: #{e.message}"
      rescue => e
        "Error: #{e.message} from #{__FILE__}:#{__LINE__}"
      end
    end

  end

end
