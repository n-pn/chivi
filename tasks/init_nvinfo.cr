require "./shared/bootstrap"

File.each_line("var/_common/nvinfos.tsv") do |line|
  frags = line.split('\t')
  next unless frags.size == 2

  btitle, author_zname = frags
  btitle, author_zname = CV::BookUtil.fix_names(btitle, author_zname)
  next if btitle.empty? || author_zname.empty?

  author = CV::Author.upsert!(author_zname)
  CV::Nvinfo.upsert!(author, btitle)
rescue err
  puts err
end
