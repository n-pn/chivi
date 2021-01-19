require "./src/mapper/value_map"

INP = "_db/_seeds/"
OUT = "_db/chdata/chinfos"

def fix(s_name : String)
  inp_file = "#{INP}/#{s_name}/_utime.tsv"
  out_file = "#{OUT}/#{s_name}/_utime.tsv"

  seed_map = CV::ValueMap.new(inp_file, mode: 0)
  info_map = CV::ValueMap.new(out_file, mode: 0)

  File.read_lines(inp_file).each do |line|
    s_nvid, d_time = line.split('\t')

    m_time = Time.parse_utc(d_time, "%F %T %:z").to_unix
    m_time = 0 if m_time < 0

    seed_map.add(s_nvid, m_time)
  end

  File.read_lines(out_file).each do |line|
    s_nvid, d_time = line.split('\t')

    m_time = seed_map.ival_64(s_nvid)

    info_map.add(s_nvid, m_time)
  end

  seed_map.save!
  info_map.save!
end

fix("xbiquge")
