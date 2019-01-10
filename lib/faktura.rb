require 'clamp'
require 'colorize'

class Faktura < Clamp::Command
  option ['-n', '--directory'], :flag, 'param is directory'
  option ['-D', '--dump'], :flag, 'dump content'
  parameter 'names ...', 'files or directories', attribute_name: :names

  def execute
    puts 'Hello.'.colorize(:yellow)
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
    puts "#{filename}: #{pdf}"
    puts pdf.content if dump?
  end
end

require 'faktura/pdf'
require 'faktura/stamp'


