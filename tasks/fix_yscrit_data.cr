require "tabkv"
require "../src/_util/time_utils"
require "../src/cvmtl/mt_core"

DIR = "var/yousuu/yscrits"

def fix_timestamp!
  glob = File.join(DIR, "*-infos.tsv")

  Dir.glob(glob).each do |file|
    infos_map = Tabkv.new(file)
    unsaved = 0

    infos_map.data.each do |ycrid, infos|
      changed = false

      ctime = infos[6]
      unless ctime.to_i64?
        puts ctime
        infos[6] = CV::TimeUtils.parse_time(ctime).to_unix.to_s
        changed = true
      end

      utime = infos[7]
      unless utime.to_i64?
        puts utime
        infos[7] = CV::TimeUtils.parse_time(utime).to_unix.to_s
        changed = true
      end

      next unless changed
      infos_map.set!(ycrid, infos)
      unsaved += 1
    end

    infos_map.save!(dirty: false) if unsaved > 0
  end
end

def fix_content!
  trads = Set(Char).new
  simps = Set(Char).new

  CV::VpDict.tradsim.data.each do |term|
    trads.concat term.key.chars

    simps.concat term.val.first.chars
  end

  trads -= simps

  glob = File.join(DIR, "*-ztext.tsv")
  Dir.glob(glob).each do |file|
    ztext_map = Tabkv.new(file)
    unsaved = 0

    ztext_map.data.each do |ycrid, ztext|
      changed = false
      is_trad = false

      ztext.each_with_index do |line, idx|
        if line.includes?('\0')
          ztext[idx] = line.gsub('\0', "")
          changed = true
        end

        next if is_trad
        is_trad = trads.intersects? Set(Char).new(line.chars)
      end

      next unless changed || is_trad

      if is_trad
        ztext = ztext.map do |line|
          list = CV::MtCore.tradsim_mtl.tokenize(line.chars)
          list.to_s
        end
      end

      unsaved += 1
      ztext_map.set!(ycrid, ztext)
    end

    ztext_map.save!(dirty: false) if unsaved > 0
  end
end

# fix_timestamp!
fix_content!
