module CV::ChSeed
  alias HashMap = Hash(String, Tuple(Int32, Int8))

  INFO_DIR = "var/fixed/seeds"
  class_getter stats_map : HashMap do
    hash = HashMap.new

    files = {"common.tsv", "viuser-live.tsv", "viuser.tsv"}

    files.each do |file|
      File.each_line("#{INFO_DIR}/#{file}") do |line|
        next if line.empty? || line.starts_with?('#')
        cols = line.split('\t')

        sname, sn_id, stype = cols
        hash[sname] = {sn_id.to_i, stype.to_i8}
      end
    end

    hash
  end

  def self.has_sname?(sname : String)
    stats_map.has_key?(sname)
  end

  def self.add_user(sname : String, sn_id : Int32) : Nil
    stats_map[sname] = {sn_id, 0_i8}

    File.open("#{INFO_DIR}/viuser-live.tsv", "a") do |io|
      io << sname << '\t' << sn_id << '\t' << 0 << '\n'
    end
  end

  def self.map_sname(sname : String) : {Int32, Int8}
    stats_map[sname] ||= raise "Invalid sname [#{sname}]"
  end

  class_getter sname_map : Hash(Int32, Tuple(String, Int8)) do
    hash = {} of Int32 => {String, Int8}

    stats_map.each do |sname, (sn_id, stype)|
      hash[sn_id] = {sname, stype}
    end

    hash
  end

  def self.is_remote?(sn_id : Int32) : Bool
    return false if sn_id % 2 == 0
    sname_map[sn_id].last > 2
  end

  def self.get_sname(sn_id : Int32) : String
    sname_map[sn_id].first
  end
end
