require "../../src/appcv/bookdb"
require "../../src/appcv/chapdb"

SITES = {
  "hetushu", "jx_la", "rengshu",
  "xbiquge", "nofff", "duokan8",
  "paoshu8", "69shu", "zhwenpg",
  "yousuu",
}

DELETED = Set(String).new

SITES.each do |site|
  infos = LabelMap.load!("_import/sites/#{site}")

  infos.each do |sbid, info|
    ubid, title, author = info.split("¦")
    new_title = BookDB::Utils.fix_zh_title(title)

    if title != new_title
      puts "- title: #{title} -> #{new_title} [#{sbid} - #{ubid}]"
      title = new_title
    end

    new_author = BookDB::Utils.fix_zh_author(author, title)

    if author != new_author
      puts "- author: #{author} -> #{new_author} [#{sbid} - #{ubid}]"
      author = new_author
    end

    new_ubid = UuidUtil.gen_ubid(title, author)

    infos.upsert(sbid, "#{new_ubid}¦#{title}¦#{author}") if ubid != new_ubid
    DELETED.add(new_ubid)
  end

  infos.save!
end

BookInfo.ubids.each do |ubid|
  next if DELETED.includes?(ubid)
  puts "- DEAD ENTRY: #{ubid}"

  File.delete(BookInfo.path_for(ubid))
  FileUtils.rm_rf(ChapList.path_for(ubid))

  OrderMap.book_access.delete!(ubid)
  OrderMap.book_update.delete!(ubid)
  OrderMap.book_weight.delete!(ubid)
  OrderMap.book_rating.delete!(ubid)

  TokenMap.zh_author.delete!(ubid)
  TokenMap.vi_author.delete!(ubid)
  TokenMap.zh_title.delete!(ubid)
  TokenMap.vi_title.delete!(ubid)
  TokenMap.vi_genres.delete!(ubid)
  TokenMap.vi_tags.delete!(ubid)
end
