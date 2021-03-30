require "colorize"
require "file_utils"

INP_TEXT = "_db/chdata/zh_txts"
INP_META = "_db/chdata/chorigs"

OUT_ZDIR = "_db/chdata/zhtexts"
OUT_META = "_db/chdata/zhinfos"

snames = ARGV.empty? ? Dir.children(INP_TEXT).sort : ARGV
snames.each { |sname| combine_texts(sname) }

def combine_texts(sname)
  books = Dir.glob File.join(INP_TEXT, sname, "*/")
  FileUtils.mkdir_p("_db/chdata/zhorigs/#{sname}")

  books.sort.each_with_index(1) do |inp_text, i|
    puts "\n[#{sname}/#{i}/#{books.size}]\n".colorize.blue.bold

    snvid = File.basename(inp_text)
    mfile = File.join(INP_META, sname, snvid + ".tsv")

    next unless File.exists?(mfile)
    chaps = File.read_lines(mfile).reject(&.empty?).map(&.split('\t'))

    out_zdir = File.join(OUT_ZDIR, sname, snvid)
    out_meta = File.join(OUT_META, sname, snvid)

    FileUtils.mkdir_p(out_zdir)
    FileUtils.mkdir_p(out_meta)

    chaps.each_slice(100).with_index do |list, idx|
      group = idx.to_s.rjust(3, '0')

      out_zip = File.join(out_zdir, group + ".zip")
      out_idx = File.join(out_meta, group + ".tsv")

      puts "- <#{idx * 100 + 1}-#{idx * 100 + 100}/#{chaps.size}> [#{out_zip}]"

      list.each_with_index(idx * 100 + 1) do |info, idx|
        info.unshift(idx.to_s)
        schid = info[1]

        inp_txt = File.join(INP_TEXT, sname, snvid, schid + ".txt")
        next unless File.exists?(inp_txt) && File.size(inp_txt) > 0

        cleanup_file(inp_txt)
        `zip -jqm "#{out_zip}" "#{inp_txt}"`
      end

      File.write(out_idx, list.map(&.join('\t')).join('\n'))
    end

    FileUtils.mv(mfile, mfile.sub("chorigs", "zhorigs"))
  end
end

def cleanup_file(file)
  lines = [] of String

  File.each_line(file) do |line|
    return unless line.includes?('¦')
    lines << line.split(/[\tǁ]/).map(&.split('¦').first).join
  end

  puts "- update file content: #{file}".colorize.red
  mtime = File.info(file).modification_time
  File.write(file, lines.join('\n')) # save new content
  File.utime(mtime, mtime, file)     # keep original modification time
end
