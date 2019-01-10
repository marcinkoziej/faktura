# coding: utf-8
require 'hexapdf'

class Faktura::Stamp
  TIMES_NEW_ROMAN = '/usr/share/fonts/truetype/msttcorefonts/Times_New_Roman.ttf'

  def initialize(pdf)
    @filename = pdf
    if pdf.class == Faktura::PDF
      @filename = pdf.filename
    end
    @start_y = 400
    @cursor_y = @start_y
  end

  RED = [200, 0, 0]
  def stamp(name, description, output=nil)
    pdf = HexaPDF::Document.open(@filename)
    @canvas = pdf.pages.add.canvas

    style = HexaPDF::Layout::Style.new
    style.font = pdf.fonts.add(TIMES_NEW_ROMAN)
    style.font_size = 12
    style.stroke_color = RED
    style.fill_color = RED
    @style = style

    put_line "Imie i nazwisko: #{name}"
    put_line "Forma płatności: zwrot poniesionych kosztów przelew karta służbowa"
    put_line "Opis kosztu: #{description}"
    put_line "Data i podpis: #{Time.now.strftime("%d-%m-%Y")}"
    hr INDENT, INDENT + LINE_WIDTH, @cursor_y
    @cursor_y -= 10
    put_line "Sprawdzono pod względem merytorycznym:"
    put_line "Sprawdzono pod względem formalnym i rachunkowym:"
    put_line "Zatwierdzono do wypłaty:"
    put_line "Data:"
    put_line "Koszt finansowany z:"
    pdf.write output_file
    true
  end

  LINE_WIDTH=500
  INDENT=50

  def put_line(text)
    puts text
    puts "cursor=#{@canvas.text_cursor}"
    tf = HexaPDF::Layout::TextFragment.create text, @style
    text_width = tf.width
    text_height = tf.height
    puts "text_width=#{text_width}"
    tl = HexaPDF::Layout::TextLayouter.new @style
    line = tl.fit([tf], LINE_WIDTH, LINE_SKIP)
    line.draw(@canvas, INDENT, @cursor_y)
    puts "fter cursor=#{@canvas.text_cursor}"

    finish_dash(INDENT + text_width + 10,
                INDENT + LINE_WIDTH - text_width,
                @cursor_y - text_height * 0.8)

    @cursor_y -= line.height * 1.5
  end

  def hr(x1, x2, y)
    @canvas.stroke_color(RED).line_dash_pattern(0).line(x1, y, x2, y).stroke
  end

  def finish_dash(x1, x2, y)
    @canvas.stroke_color RED
    @canvas.line_dash_pattern = [1, 5]
    @canvas.line_width = 0.5
    @canvas.line(x1, y, x2, y)
    @canvas.stroke
  end

  def output_file
    dir = File.dirname(@filename)
    ext = File.extname(@filename)
    base = File.basename(@filename, ext)
    File.expand_path "#{base}_stamped#{ext}", dir
  end

end
