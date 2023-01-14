require "../../src/mt_v2/*"

DIR = "_db/vpinit/legacy"

def read_file(file : String)
  hash = {} of String => Array(String)

  File.read_lines(file).each do |line|
    rows = line.split('\t')
    next if rows.size < 2
    key, val = rows
    next if val.empty?
    hash[key] = val.split(CV::VpTerm::SPLIT)
  end

  hash
end

def save_old(file, out_name)
  vp_main = read_file("#{DIR}/#{file}-main.tsv")
  vp_pleb = read_file("#{DIR}/#{file}-pleb.tsv")

  vp_main.merge!(vp_pleb) do |_k, v1, v2|
    v1.concat(v2).uniq!
  end

  output = vp_main.to_a.map { |k, v| "#{k}=#{v.join("/")}" }
  File.write("#{DIR}/output/#{out_name}.txt", output.join("\n"))
end

save_old("regular", "VietPhrase-old")
save_old("combine", "Names-old")

def export_vpdict(name : String, out_name = name)
  vdict = CV::VpDict.load(name)
  out_file = "#{DIR}/output/#{out_name}.txt"

  out_text = [] of String

  vdict.data.each do |vpterm|
    next if vpterm._flag > 0 || vpterm.val.first? == ""

    out_text << "#{vpterm.key}=#{vpterm.val.join("/")}"
  end

  File.write(out_file, out_text.join("\n"))
end

export_vpdict("regular", "VietPhrase-new")
export_vpdict("combine", "Names-new")
export_vpdict("hanviet", "ChinesePhienAmWords")
