require "file_utils"

module CV::PathUtil
  extend self

  CACHE_DIR = "_db/.cache"
  SEEDS_DIR = "_db/_seeds"

  # sname: "hetushu", "jx_la", etc.
  def cache_dir(sname : String)
    "#{CACHE_DIR}/#{sname}"
  end

  # subdirs: `infos`, `chaps`, etc.
  def cache_dir(sname : String, subdir : String)
    "#{CACHE_DIR}/#{sname}/#{subdir}"
  end

  # fname: `1.html.gz`, `infos/4.json`, etc.
  def cache_file(sname : String, fname : String)
    "#{CACHE_DIR}/#{sname}/#{fname}"
  end

  # sname: "hetushu", "jx_la", etc.
  def seeds_dir(sname : String)
    "#{SEEDS_DIR}/#{sname}"
  end

  # subdirs: `covers`, `intros`, etc.
  def seeds_dir(sname : String, subdir : String)
    "#{SEEDS_DIR}/#{sname}/#{subdir}"
  end

  # fname: `_index`, `status`, `genres`, etc.
  def seeds_map(sname : String, fname : String)
    "#{SEEDS_DIR}/#{sname}/#{fname}.tsv"
  end

  def binfo_cpath(sname : String, snvid : String)
    cache_file(sname, "infos/#{snvid}.html.gz")
  end

  def chdix_cpath(sname : String, snvid : String)
    cache_file(sname, "infos/#{snvid}-mulu.html.gz")
  end
end
