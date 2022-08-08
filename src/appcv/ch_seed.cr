class CV::ChSeed
  class_getter sname_map : Hash(String, {Int32, Int8}) do
    output = {} of String => {Int32, Int8}

    File.read_lines("var/fixed/sn_id.tsv").each do |line|
      next if line.empty? || line.starts_with?('#')
      cols = line.split('\t')
      output[cols[0]] = {cols[1].to_i, cols[2].to_i8}
    end

    output
  end

  def self.map_sname(sname : String) : {Int32, Int8}
    sname_map[sname] ||= begin
      raise "Invalid seed name" unless sname.starts_with?('@')
      user_id = Viuser.load!(sname[1..]).id
      {user_id &* 2 &+ 20, 1_i8}
    end
  end
end
