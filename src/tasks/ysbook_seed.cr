require "../../ysapp/data/ysbook_data"
require "../../zroot/data/ysbook"

require "../../_data/wnovel/wninfo"
require "../../_data/wnovel/wnlink"
require "../../mt_v1/data/v1_dict"

YDB = ZR::Ysbook.db

SELECT_SQL = ZR::Ysbook.schema.select_stmt { |stmt| stmt << "where id >= $1 and id <= $2" }

def load_wninfo(ysbook : ZR::Ysbook, force : Bool = false)
  case self.nvinfo_id
  when 0    then create_nvinfo if force || worth_saving?
  when .> 0 then CV::Wninfo.find({id: self.nvinfo_id})
  else           nil
  end
end

def sync_with_wn!(input : ZR::Ysbook)
  ztitle, zauthor = BookUtil.fix_names(input.btitle, input.author)
  author = CV::Author.upsert!(zauthor, zauthor)
  btitle = CV::Btitle.upsert!(ztitle, ztitle)
end

(0..).each do |block|
  lower = block &* 1000
  upper = lower &+ 999

  inputs = YDB.query_all SELECT_SQL, lower, upper, as: ZR::Ysbook

  puts "- block: #{block}, books: #{inputs.size}"
  break if inputs.empty?
end