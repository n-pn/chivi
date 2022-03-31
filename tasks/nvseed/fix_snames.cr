require "../shared/bootstrap"

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
    out_dir = dir.sub(source, target)
    File.rename(out_dir, out_dir + ".old") if File.exists?(out_dir)
    File.rename(dir, out_dir)
  end

  CV::Nvseed.query.where(sname: source).each do |zhseed|
    zhseed.update({sname: target})
  end

  CV::Ubmemo.query.where(lr_sname: source).each do |ubmemo|
    ubmemo.update({lr_sname: target})
  end
end

# rename_seed("nofff", "sdyfcm")
# rename_seed("bqg_5200", "biqu5200")
# rename_seed("biqubao", "biqugee")

FileUtils.rm_rf("var/chtexts/chivi")
FileUtils.mkdir_p("var/chtexts/chivi")
CV::Nvseed.query.where(zseed: 0).to_update.set(chap_count: 0).execute
