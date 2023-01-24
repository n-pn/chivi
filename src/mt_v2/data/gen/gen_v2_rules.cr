require "yaml"
require "../v2_ptag"
require "../v2_rule"
require "colorize"

db_path = M2::DbRule.db_path
File.delete?(db_path)

ptags = {} of String => Int32

extds = {} of Int32 => Array(String)

M2::DbPtag.repo.open_db do |db|
  db.query_each "select id, alts, lbls from ptags" do |rs|
    id, ptag, extd = rs.read(Int32, String, String)
    ptags[ptag] = id
    extds[id] = extd.split(" | ")
  end
end

extds.each do |ptag_id, rhs_list|
  rhs_list.each do |ptag|
    next if ptag.blank?

    unless rhs_id = ptags[ptag]?
      puts "missing: #{ptag}"
      next
    end

    rule = M2::DbRule.new
    rule.rule = ",#{ptag_id},"
    rule.size = 1
    rule.prio = 5

    rule.ptag = rhs_id
    rule.kind = 2

    puts "#{ptag_id} => #{ptag}"

    rule.save!
  end
end

struct RawRule
  include YAML::Serializable

  getter rule : Array(String)
  getter ptag : String

  getter swap : Array(Int32)?
  getter cost : Int32 = 10
end

files = Dir.glob("var/cvmtl/rules/*.yml").sort!

files.each do |file|
  data = File.read(file)
  Array(RawRule).from_yaml(data).each do |input|
    rule = M2::DbRule.new

    ptag_ids = input.rule.map { |x| ptags[x] }
    rule.rule = ",#{ptag_ids.join(',')},"

    rule.size = input.rule.size
    rule.prio = input.cost

    if input.ptag[0] == '$'
      ptag_out = input.rule[input.ptag[1..].to_i - 1]
    else
      ptag_out = input.ptag
    end

    rule.ptag = ptags[ptag_out]
    rule.kind = 0

    if swap = input.swap
      rule._combine = swap.join(",")
    end

    # puts "adding: #{input.rule}"
    rule.save!
  rescue err
    puts [err, file].colorize.red
  end
end
