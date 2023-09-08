require "sqlite3"

DIC = DB.open("sqlite3:var/mtdic/fixed/hints/all_terms.dic")
at_exit { DIC.close }

def find_value(zh : String)
  query = "select vi from terms where zh = ?"
  DIC.query_one?(query, zh, as: String) || ""
end

def fill_viet(file : String, fill_all = false)
  output = File.open(file + ".tsv", "w")
  File.each_line(file) do |line|
    if line.empty? || line.starts_with?('#')
      output.puts line
      next
    end

    args = line.split('\t')
    args << "" if args.size == 1
    args << "?" if args.size == 2

    word = args[0]
    defn = args[1]

    unless defn.empty?
      output.puts args.join('\t')
      next unless fill_all
    end

    defined = find_value(word)
    next if defined.empty?

    defined.split('\t').each do |val|
      args[1] = val
      output.puts args.join('\t')
    end
  end

  output.close
end

def file_path(path : String)
  "var/mt_v2/inits/#{path}"
end

fill_all = ARGV.includes?("-f")

ARGV.each do |arg|
  next if arg[0] == '-'
  fill_viet file_path(arg), fill_all: fill_all
end
