require "../src/_util/char_util"
require "../src/_util/viet_util"
require "../src/mt_sp/data/v_cache"

type = SP::VCache::Obj::C_gpt

zh_paths = Dir.glob("/www/npn-chivi/*/zh/*.txt")

zh_paths.each do |zh_path|
  vi_path = zh_path.sub("/zh/", "/vi/")

  zh_lines = File.read(zh_path).strip.split(/\R/).map! { |line| CharUtil.trim_sanitize(line) }
  vi_lines = File.read(vi_path).strip.split(/\R\R/).map! { |line| VietUtil.fix_tones(line.strip) }

  unless zh_lines.size == vi_lines.size
    next puts "[#{zh_path}] and [#{vi_path}] unmatched! (#{zh_lines.size}) vs (#{vi_lines.size})"
  end

  if vi_lines.any?(&.empty?)
    next puts "[#{vi_path}] has blank lines, skipping!"
  end

  SP::VCache.cache!(type, zh_lines, vi_lines)
  puts "#{zh_path} cached!"
rescue ex
  puts ex
end
