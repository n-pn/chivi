require "compress/zip"

def export(sname, sn_id, fname, wndic = "combine")
  zip_path = "/2tb/zroot/ztext/#{sname}/#{sn_id}.zip"

  Compress::Zip::File.open(zip_path) do |zip|
    entries = zip.entries.sort_by(&.filename)

    out_data = {} of Int32 => String

    entries.each do |entry|
      ch_no = File.basename(entry.filename, ".zh").to_i // 10
      out_data[ch_no] = entry.try(&.open(&.gets_to_end))
    end

    out_path = "/2tb/zroot/texts/#{fname}.#{wndic}.txt"

    File.open(out_path, "w") do |file|
      data = out_data.to_a.sort_by!(&.[0])
      data.map(&.[1]).join(file, "\n\n\n")
    end

    size = out_data.values.sum(&.size)
    size = size // 100000 * 100000
    puts "#{fname}: <#{wndic}> #{size}"

    size
  end
end

total = 0
puts total
puts (total.to_i64 * 20) // 1_000_000
