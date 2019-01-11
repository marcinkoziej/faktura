
module Faktura
  class CLI < Clamp::Command
    include Faktura::Helpers
    option ['-n', '--directory'], :flag, 'param is directory'
    option ['-D', '--dump'], :flag, 'dump content'
    option ['-s', '--stamp'], :flag, 'stamp invoice'
    option ['-p', '--printer'], 'PRINTER', 'print (stamped) invoice'
    option ['-o', '--open'], :flag, 'open (stamped) invoice'
    option ['-w', '--window'], :flag, 'Ask using a dialog window'
    parameter 'names ...', 'files or directories', attribute_name: :names

    def execute
      names.each do |name|
        if directory?
          Dir["#{name}/**/*.pdf"].each do |fn|
            process fn
          end
        else
          process name
        end
      end
    end

    def process(filename)
      pdf = PDF.new filename
      stamped_filename = nil

      puts "#{filename}: #{pdf}".colorize(:light_blue)
      if dump?
        puts pdf.content
      end

      if stamp?
        stamper = Faktura::Stamp.new(pdf)
        stamped = stamper.stamp(get_name, get_description(pdf))
        stamped_filename = output_file(filename)
        stamped.write stamped_filename
        puts "Created file #{stamped_filename}".colorize(:light_yellow)
      end

      if printer
        puts "Printing #{stamped_filename || filename} to printer #{printer}".colorize(:green)
        system('lpr', '-o', 'sides=two-sided-long-edge', '-P', printer, stamped_filename || filename)
      end

      if open?
        system('xdg-open', stamped_filename || filename)
      end
    end
  end
end
