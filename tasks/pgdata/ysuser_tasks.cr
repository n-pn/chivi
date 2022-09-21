# require "../shared/yslist_raw"
require "../shared/nvinfo_util"

module CV
  def self.reseed!
    Tabkv(Int32).new("var/ysinfos/ysusers.tsv").data.each do |zname, origin_id|
      zname = zname.gsub("'", "''")
      Clear::SQL.execute <<-SQL
        update ysusers set origin_id = #{origin_id} where zname = '#{zname}';
      SQL

    rescue err
      puts err
    end
  end

  def self.update!
    YS::Ysuser.query.each do |ysuser|
      ysuser.fix_name

      ysuser.list_count = Yslist.query.where("ysuser_id = ?", ysuser.id).count.to_i
      ysuser.crit_count = Yscrit.query.where("ysuser_id = ?", ysuser.id).count.to_i

      ysuser.save!
    end
  end

  reseed! if ARGV.includes?("reseed")
  update! if ARGV.includes?("update")
end
