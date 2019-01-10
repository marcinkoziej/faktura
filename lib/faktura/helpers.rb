module Faktura
  module Helpers
    def output_file(filename, postfix = '_stamped')
      dir = File.dirname(filename)
      ext = File.extname(filename)
      base = File.basename(filename, ext)
      File.expand_path "#{base}#{postfix}#{ext}", dir
    end

    def get_name
      pw = Etc.getpwnam Etc.getlogin
      fn = pw.gecos.split(',').first
      if fn.nil?
        ask_for "I don't know your full name, please specify: "
        STDIN.gets.chomp
      else
        fn
      end
    end

    def get_description(invoice)
      prov = invoice.provider
      if prov && (desc = description_for(prov))
        return desc
      else
        ask_for "Can't out the invoice description. Write one: "
      end
    end

    def ask_for(question)
      if window?
        IO.popen(['zenity', '--entry', '--text=' + question]) do |pin, _pout|
          pin.gets.chomp
        end
      else
        print question.colorize(:light_red)
        STDIN.gets.chomp
      end
    end

    def description_for(provider)
      @providerdb ||= YAML.safe_load(open(File.expand_path('faktura.yml', File.dirname(__FILE__))))
      @providerdb['description'][provider.to_s]
    end
  end
end
