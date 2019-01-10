# coding: utf-8
class Faktura::PDF
  attr_reader :filename
  attr_reader :content
  attr_reader :date
  attr_reader :amount
  attr_reader :provider
  attr_reader :currency

  def initialize(filename)
    @filename = filename
    @content = read
    @date = nil
    @provider = nil
    @currency = nil

    analyze
    unless provider
      puts "UNKNOWN".colorize(:red)
      puts content
    end
  end

  def read
    IO.popen(['pdftotext', @filename, '-']) do |io|
      io.read
    end
  end

  def analyze
    SIGNATURES.each do |prv, opt|
      if content =~ opt[:name]
        @provider = prv
        @currency = opt[:currency]

        if opt.has_key? :date and date_m = content.match(opt[:date])
          @date = date_m[1]
        end

        if opt.has_key? :amount and amount_m = content.match(opt[:amount])
          @amount = amount_m[1]
        end

      end
    end
  end

  SIGNATURES = {
    csl: {
      name: /ChangeSprout Inc./,
      date: /Issue Date:\n+(\d+ \w+ \d+)/,
      amount: /Amount Due\n\n([\d.]+)/,
      currency: 'USD'
    },
    aws: {
      name: /Amazon Web Services/,
      date: /Invoice Date:\n+\d+\n(\w+ \d+ *, *\d+)/,
      amount: /TOTAL AMOUNT DUE[^\n]+\n\n[$]([\d.]+)/,
      currency: 'USD'
    },
    freshdesk: {
      name: /Freshworks Inc./,
      date: /Invoice Date (\w+ \d+, \d+)/,
      amount: /Invoice Amount ([\d,]+) €/,
      currency: 'EUR'
    },
    newrelic: {
      name: /New Relic Inc./,
      date: /Description\n+\w+ \d+ - (\w+ \d+ \d+)/,
      amount: /Total Due[^\n]+\n+[$]([\d.]+)/,
      currency: 'USD'
    },
    ovh: {
      name: /OVH Sp. z o.o./,
      date: /Data wystawienia: ([\d-]+)/,
      amount: /Razem brutto.+(^[\d.]+) PLN/m,
      currency: 'PLN'
    },
    zoom: {
      name: /Zoom Video Communications/,
      date: /Transaction\nType\n+([\d\/]+)/,
      amount: /Applied\nAmount\n[($]+([\d.]+)[)]/,
      currency: 'USD'
    }
    
  }

  def to_s
    "#{provider} (#{date}) #{currency}#{amount or '???'}"
  end
end
