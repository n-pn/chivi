require "json"
require "file_utils"

require "../filedb/*"

module Oldcv::ChapMeta
  class Item
    property index = 0
    property b_cid = ""
    property vi_label = ""
    property vi_title = ""
    property url_slug = ""
  end

  class List
    DIR = "_db/prime/chdata/infos"
    FileUtils.mkdir_p(DIR)

    getter sname = ""
    getter s_bid = ""

    property ch_index : OrderMap { OrderMap.new(file_path("ch_index")) }
    property zh_title : OrderMap { ValueMap.new(file_path("zh_title")) }
    property vi_title : OrderMap { ValueMap.new(file_path("vi_title")) }
    property url_slug : OrderMap { ValueMap.new(file_path("url_slug")) }

    def initialize(@sname, @s_bid)
      @dir = File.join(DIR, @sname, @s_bid)
      FileUtils.mkdir_p(@dir)
    end

    private def file_path(name : String)
      File.join(@dir, "#{name}.tsv")
    end

    def each(index : Int32 = 0, limit : Int32 = 50)
      limit = ch_index.size if limit < 0

      ch_index.each do |b_cid, idx|
        if index > 0
          index -= 1
        else
          yield b_cid, idx

          limit -= 1
        end

        break if limit < 0
      end
    end

    def reverse_each(index : Int32 = 0, limit : Int32 = 4)
      limit = ch_index.size if limit < 0

      ch_index.reverse_each do |key, idx|
        if index > 0
          index -= 1
        else
          yield b_cid, idx
          limit -= 1
        end

        break if limit < 0
      end
    end

    def get_index(b_cid : String)
      ch_index.get_index(b_cid)
    end

    def get_vi_title(b_cid : String)
      vi_title.get_value(b_cid)
    end

    def get_url_slug(b_cid : String)
      url_slug.get_value(b_cid)
    end
  end
end
