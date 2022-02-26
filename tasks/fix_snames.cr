require "./shared/bootstrap"

def rename_seed(from source : String, to target : String)
  dirs = {
    "_db/.cache/#{source}",
    "_db/bcover/#{source}",
    "_db/zhbook/#{source}",
    "var/chtexts/#{source}",
    "var/nvinfos/autos/#{source}",
  }

  dirs.each do |dir|
    next unless File.exists?(dir)
    File.rename(dir, dir.sub(source, target))
  end

  CV::Zhbook.query.where(sname: source).each do |nvchap|
    nvchap.update({sname: target})
  end

  CV::Ubmemo.query.where(lr_sname: source).each do |ubmemo|
    ubmemo.update({lr_sname: target})
  end
end

rename_seed("nofff", "sdyfcm")
rename_seed("bqg_5200", "biqu5200")
rename_seed("biqubao", "biqugee")
