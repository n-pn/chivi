# require "colorize"
# require "file_utils"
# require "compress/zip"

# require "../../src/_util/file_util"
# require "../../src/wnapp/data/*"

# struct Chap
#   property chdiv : String
#   property lines : Array(String)
#   getter title : String { lines[0]? || "" }

#   def initialize(@chdiv, @lines)
#   end
# end

# RARS_DIR = "var/seeds/zxcs_me/_rars"
# TEXT_DIR = "var/seeds/zxcs_me/texts"

# SAVE_DIR = "var/chaps/texts/zxcs_me"

# def extract_all!
#   input = Dir.glob("#{RARS_DIR}/*.rar")
#   output = [] of String

#   input.each_with_index(1) do |rar_file, idx|
#     next unless file = extract_rar!(rar_file, label: "#{idx}/#{input.size}")
#     output << file
#   end

#   # `python3 tasks/zxcsme/fix_mtime.py`

#   output.each_with_index do |file, idx|
#     split_chaps!(file, "#{idx}/#{output.size}")
#   end
# end

# def extract_rar!(rar_file : String, label = "1/1")
#   s_bid = File.basename(rar_file, ".rar")
#   out_path = "#{TEXT_DIR}/#{s_bid}.txt"

#   return out_path if File.exists?(out_path)
#   puts "\n- <#{label}> extracting #{rar_file.colorize.blue}"

#   tmp_dir = "tmp/zxcs.me/#{s_bid}"
#   Dir.mkdir_p(tmp_dir)

#   `unrar e -o+ "#{rar_file}" #{tmp_dir}`
#   txt_path = Dir.glob("#{tmp_dir}/*.{txt,TXT}").first

#   lines = read_clean(txt_path)
#   File.write(out_path, lines.join("\n"))

#   FileUtils.rm_rf(tmp_dir)
#   out_path
# rescue err
#   puts err
# end

# FILE_RE_1 = /《(.+)》.+作者：(.+)\./
# FILE_RE_2 = /《(.+)》(.+)\.txt/

# private def read_clean(inp_file : String) : Array(String)
#   lines = FileUtil.read_utf8(inp_file).strip.split(/\R/)

#   if lines.first.starts_with?("===")
#     while line = lines.shift?
#       break if line.starts_with?("===")
#     end

#     while line = lines.pop?
#       break if line.starts_with?("===")
#     end
#   end

#   if match = FILE_RE_1.match(inp_file) || FILE_RE_2.match(inp_file)
#     _, title, author = match
#   else
#     puts "invalid file name!".colorize.red
#     exit 0
#   end

#   while is_garbage?(lines.first, title, author)
#     lines.shift
#   end

#   while is_garbage_end?(lines.last)
#     lines.pop
#   end

#   lines
# end

# GARBAGES = {
#   /^#{title}/,
#   /《#{title}》/,
#   /书名[：:]\s*#{title}/,
#   /作者[：:]\s*#{author}/,
#   /^分类：/,
#   /^字数：：/,
# }

# private def is_garbage?(line : String, title : String, author : String)
#   return true if is_garbage_end?(line)
#   GARBAGES.any?(&.matches?(line))
# end

# private def is_garbage_end?(line : String)
#   line.empty? || line.starts_with?("更多精校小说")
# end

# SKIP_CHOICE = ARGV.includes?("--skip")

# def split_chaps!(inp_file : String, label = "1/1")
#   s_bid = File.basename(inp_file, ".txt")

#   global_idx = File.join("var/seeds/zxcs.me/infos", "#{s_bid}.tsv")

#   input = File.read(inp_file).split(/\R/)
#   out_dir = File.join(SAVE_DIR, s_bid)

#   # TODO: remove these hacks
#   # input = reclean_text!(inp_file, input)

#   puts "\n- <#{label}> [#{TEXT_DIR}/#{s_bid}.txt] #{input.size} lines".colorize.yellow

#   return unless chaps = split_chapters(s_bid, input)
#   chaps = cleanup_chaps(chaps)

#   index = chaps.map_with_index(1) do |chap, idx|
#     [(idx + 1).to_s, chap.title, chap.label]
#   end

#   if good_enough?(index)
#     save_texts!(chaps, out_dir, inp_file, global_idx)
#     return
#   end

#   puts "\n- <#{label}> [#{TEXT_DIR}/#{s_bid}.txt] #{input.size} lines".colorize.yellow
#   return puts "  Skipped".colorize.red if SKIP_CHOICE

#   print "\nChoice (r: redo, d: delete, s: delete + exit, else: keep): "

#   STDIN.flush
#   case char = STDIN.raw(&.read_char)
#   when 'd', 's', 'r'
#     FileUtils.rm_rf(out_dir)
#     puts "\n\n- [#{out_dir}] deleted! (choice: #{char})".colorize.red

#     if char == 'r'
#       split_chaps!(inp_file, label)
#     elsif char == 's'
#       exit(0)
#     end
#   else
#     save_texts!(chaps, out_dir, inp_file, global_idx)
#     puts "\n\n- Entries [#{s_bid}] saved!".colorize.yellow
#   end
# end

# # def reclean_text!(inp_file : String, lines : Array(String))
# #   changed = false

# #   if lines.first.match(/^\s*===/)
# #     changed = true

# #     3.times { lines.shift; lines.pop }

# #     lines.shift if lines.first.match(/^\s*===/)
# #     lines.pop if lines.last.match(/^\s*===/)
# #   end

# #   while lines.first.empty? || lines.first.match(/^分类：|作者：|类别：|字数：/)
# #     changed = true
# #     lines.shift
# #   end

# #   File.write(inp_file, lines.join("\n")) if changed
# #   lines
# # rescue
# #   puts [inp_file, lines]
# #   exit(0)
# # end

# def save_texts!(chaps, nv_dir : String, text_file : String, global_file : String)
#   utime = File.info(text_file).modification_time.to_unix

#   s_bid = File.basename(nv_dir)

#   global = [] of ChInfo0

#   chaps.each_slice(128).with_index do |slice, idx|
#     chlist = [] of ChInfo0

#     out_dir = File.join(nv_dir, idx.to_s)
#     Dir.mkdir_p(out_dir)

#     out_zip = File.join(nv_dir, "#{idx}.zip")
#     out_idx = File.join(nv_dir, "#{idx}.tsv")

#     slice.each_with_index(1) do |chap, chidx|
#       chidx = (chidx + 128 &* idx)

#       chinfo = ChInfo0.new(chidx, chidx.to_s, chap.title, chap.label)
#       chinfo.stats.utime = utime

#       chtext = ChText.new("zxcs_me", s_bid, chinfo)
#       chtext.save!(chap.lines, zipping: false)

#       chlist << chinfo
#       global << chinfo
#     end

#     `zip --include=\\*.txt -rjmq #{out_zip} #{out_dir}`
#     ChList.save!(out_idx, chlist, "w")

#     puts "#{out_zip} saved!"
#     Dir.delete(out_dir)
#   end

#   ChList.save!(global_file, global, "w")
# end

# # ameba:disable Metrics/CyclomaticComplexity
# private def split_chapters(s_bid : String, lines : Array(String))
#   case s_bid
#   when "4683", "3868", "4314", "3199", "4942", "1552"
#     return split_blanks(lines)
#   when "3401"
#     return split_delimit(lines)
#   end

#   blanks_single, blanks_double, blanks_count = 0, 0, 0
#   unnest_count, nested_count = 0, 0

#   lines.each_with_index do |line, idx|
#     break if idx > 1000

#     if line.empty?
#       blanks_count += 1
#       next
#     end

#     if blanks_count > 1
#       blanks_double += 1
#     elsif blanks_count > 0
#       blanks_single += 1
#     end

#     blanks_count = 0

#     if nested?(line)
#       nested_count += 1
#     else
#       unnest_count += 1
#     end
#   end

#   return split_blanks(lines) if blanks_double > 1
#   return split_nested(lines) if nested_count > 1 && unnest_count > 1

#   if unnest_count == 0
#     return split_delimit(lines) if blanks_single > 0
#   end

#   puts "-- [ unsupported file format, skipping! ]".colorize.cyan
#   nil
# end

# private def nested?(line : String)
#   line =~ /^[　\s]{2,}/
# end

# private def split_nested(input : Array(String))
#   chaps = [] of Array(String)
#   lines = [] of String

#   input.each do |line|
#     next if line.empty?

#     unless lines.empty? || nested?(line)
#       chaps << lines
#       lines = [] of String
#     end

#     lines << line.strip
#   end

#   chaps << lines unless lines.empty?

#   puts "-- [ splited nested: #{chaps.size} chaps ]".colorize.cyan
#   chaps
# end

# private def split_delimit(input : Array(String))
#   chaps = [] of Array(String)
#   lines = [] of String

#   input.each do |line|
#     if line.empty?
#       if lines.size > 1
#         chaps << lines
#         lines = [] of String
#       end
#     else
#       lines << line.strip
#     end
#   end

#   chaps << lines unless lines.empty?

#   puts "-- [ splited delimit: #{chaps.size} chaps ]".colorize.cyan
#   chaps
# end

# def cleanup_chaps(input : Array(Array(String)))
#   while is_intro?(input.first)
#     input.shift
#   end

#   chaps = [] of Chap
#   chdiv = ""

#   input.each do |lines|
#     if lines.size == 1
#       chdiv = lines.first
#     else
#       chaps << Chap.new(chdiv.strip, lines.map(&.strip))
#     end
#   end

#   chaps
# end

# INTROS = {
#   "简介：",
#   "介绍：",
#   "内容概要：",
#   "作品介绍",
#   "作品简介",
#   "作者简介",
#   "内容简介",
#   "内容介绍",
#   "内容说明",
#   "书籍介绍",
#   "书籍简介",
#   "小说简介",
# }

# private def is_intro?(chap : Array(String))
#   return true if chap.last =~ /^作者：/
#   INTROS.any? { |x| chap.first.includes?(x) }
# end

# private def good_enough?(index : Array(Array(String)))
#   idx, title, _ = index.last
#   return true if title.includes?("第#{idx}章")

#   bads = [] of String

#   index.each do |info|
#     _, title, label = info

#     case label
#     when "序", "外传", "番外", "外篇", "番外篇",
#          "作品相关", "【作品相关】"
#       next
#     else
#       if label.size > 20
#         bads << "#{title} -- #{label}"
#         next
#       end
#     end

#     case title
#     when "引言", "结束语", "引 子", "开始", "感言", "前言",
#          "锲子", "结语", "楔子", "作者的话", "小结",
#          .includes?("后记"),
#          .includes?("完本了"),
#          .includes?("作品相关"),
#          .includes?("结束感言"),
#          .includes?("完本感言"),
#          .includes?("完结感言"),
#          .includes?("完稿感言"),
#          .includes?("完稿感言"),
#          .includes?("结后感言"),
#          .includes?("全本感言"),
#          .includes?("次卷预告"),
#          .includes?("写在结束的话"),
#          .=~(/^【?(序|第|终卷|楔子|引子|尾声|番外|终章|末章|终曲|后记|后续|结局)/),
#          .=~(/^【?(前记|篇外|前言|后篇|外传|尾章|初章|引章|卷末|最终回|最终章|终结章|终之章|大结局|人物介绍|更新说明)/),
#          .=~(/^\d+、/),
#          .=~(/^[【\[\(]\d+[】\]\)]/),
#          .=~(/^章?[零〇一二两三四五六七八九十百千+]^/)
#       next
#     else
#       bads << "#{title} -- #{label}"
#     end
#   end

#   if bads.empty?
#     puts "\nSeems good enough, skip checking!".colorize.green
#     true
#   else
#     puts "\n- wrong format (#{bads.size}): ", bads.first(30).join("\n\n").colorize.red
#     false
#   end
# end

# # worker = CV::Zxcs::SplitText.new
# extract_all!
