# coding: utf-8
require 'hexapdf'

class Faktura::Stamp
  TIMES_NEW_ROMAN = '/usr/share/fonts/truetype/msttcorefonts/Times_New_Roman.ttf'

  START_Y = 300
  RED = [200, 0, 0]
  INDENT=50
  RIGHT_END=400
  SKIP_LINE=18

  def initialize(pdf)
    @filename = pdf
    @overlay = false
    if pdf.class == Faktura::PDF
      @filename = pdf.filename
      @overlay = pdf.overlay
    end
    @start_y = START_Y
    @cursor_y = @start_y
  end

  def stamp(name, description, output_file=nil)
    pdf = HexaPDF::Document.open(@filename)

    puts "pages #{pdf.pages.length}"

    if pdf.pages.length > 1 and @overlay
      @canvas = pdf.pages[1].canvas(type: :overlay)
    else
      @canvas = pdf.pages.add.canvas
    end

    style = HexaPDF::Layout::Style.new
    style.font = pdf.fonts.add(TIMES_NEW_ROMAN)
    style.font_size = 12
    style.stroke_color = RED
    style.fill_color = RED
    @style = style


    put_line "Imie i nazwisko: #{name}", dashes: false
    put_line "Forma płatności: zwrot poniesionych kosztów/przelew/karta służbowa", dashes: false
    put_line "Opis kosztu: #{description}", dashes: false
    put_line "Data i podpis: #{Time.now.strftime("%d-%m-%Y")}"
    hr INDENT, RIGHT_END, @cursor_y + SKIP_LINE/2
    @cursor_y -= SKIP_LINE / 2
    put_line "Sprawdzono pod względem merytorycznym:"
    put_line "Sprawdzono pod względem formalnym i rachunkowym:"
    put_line "Zatwierdzono do wypłaty:"
    put_line "Data:"
    put_line "Koszt finansowany z:"
    if output_file
      pdf.write output_file
    end
    pdf
  end

  def put_line(text, dashes: true)
    @canvas.font(@style.font, size: 12)
    @canvas.fill_color(@style.fill_color)

    @canvas.move_text_cursor(offset: [INDENT, @cursor_y], absolute: true)
    @canvas.text(text)
    text_end = @canvas.text_cursor[0]

    if dashes
      finish_dash(text_end + 10,
                  RIGHT_END,
                  @cursor_y)
    end

    @cursor_y -= SKIP_LINE
  end

  def hr(x1, x2, y)
    @canvas.stroke_color(RED).line_dash_pattern(0).line_width(1).line(x1, y, x2, y).stroke
  end

  def finish_dash(x1, x2, y)
    @canvas.stroke_color RED
    @canvas.line_dash_pattern = [1, 5]
    @canvas.line_width = 0.5
    @canvas.line(x1, y, x2, y)
    @canvas.stroke
  end
end
