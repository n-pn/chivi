require "./vi_user"

class CV::ChSeed
  class_getter stats_map : Hash(String, {Int32, Int8}) do
    output = {} of String => {Int32, Int8}

    File.read_lines("var/fixed/sn_id.tsv").each do |line|
      next if line.empty? || line.starts_with?('#')
      cols = line.split('\t')
      output[cols[0]] = {cols[1].to_i, cols[2].to_i8}
    end

    output
  end

  def self.map_sname(sname : String) : {Int32, Int8}
    stats_map[sname] ||= begin
      user_id = Viuser.load!(sname[1..]).id
      {user_id &* 2 &+ 20, 0_i8}
    end
  end

  class_getter sname_map : Hash(Int32, Tuple(String, Int8)) do
    output = {} of Int32 => {String, Int8}
    stats_map.each do |sname, (ns_id, stype)|
      output[ns_id] = {sname, stype}
    end

    output
  end

  def self.is_remote?(sn_id : Int32) : Bool
    return false if sn_id % 2 == 0
    sname_map[sn_id]?.try(&.[1].> 2) || false
  end

  def self.get_sname(sn_id : Int32) : String
    info = sname_map[sn_id] ||= begin
      uname = "@" + Viuser.load!(sn_id // 2).uname
      {uname, 0_i8}
    end

    info[0]
  end
end
