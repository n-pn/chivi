# require "../shared/yslist_raw"
require "../shared/nvinfo_util"

module CV
  # def self.reseed!
  #   Dir.glob("_db/yousuu/list-infos/*.json") do |file|
  #     input = YslistRaw.from_info(File.read(file))
  #     stime = NvinfoUtil.mtime(file).not_nil!

  #     input.seed!(stime)
  #   rescue err
  #     puts err
  #   end
  # end

  def self.update!
    Ysuser.query.each do |ysuser|
      ysuser.fix_name

      ysuser.list_count = Yslist.query.where("ysuser_id = ?", ysuser.id).count.to_i
      ysuser.crit_count = Yscrit.query.where("ysuser_id = ?", ysuser.id).count.to_i

      ysuser.save!
    end
  end

  # reseed! if ARGV.includes?("reseed")
  update! if ARGV.includes?("update")
end
