require "sqlite3"

DIC = DB.open("sqlite3:var/cvhlp/top_terms.dic")
at_exit { DIC.close }

def find_value(word : String)
  query = "select defn from terms where word = ?"
  DIC.query_one?(query, word, as: String).try(&.tr("\v", "/")) || "?"
end

def fill_viet(file : String, fill_all = false)
  output = File.open(file + ".tab", "w")
  File.each_line(file) do |line|
    if line.empty? || line.starts_with?('#')
      output.puts line
      next
    end

    args = line.split('\t')
    args << "" if args.size == 1

    word = args[0]
    defn = args[1]

    if fill_all || defn == ""
      new_defn = find_value(word)
      args[1] = defn.empty? ? new_defn : "#{new_defn} /#{defn}"
    end

    output.puts args.join('\t')
  end

  output.close
end

def file_path(path : String)
  "var/cvmtl/inits/#{path}"
end

fill_all = ARGV.includes?("-f")

ARGV.each do |arg|
  next if arg[0] == '-'
  fill_viet file_path(arg), fill_all: fill_all
end
