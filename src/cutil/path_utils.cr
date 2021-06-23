require "file_utils"

module CV::PathUtils
  extend self

  CACHE_DIR = "_db/.cache"
  SEEDS_DIR = "_db/_seeds"

  # zseed: "hetushu", "jx_la", etc.
  def cache_dir(zseed : String)
    "#{CACHE_DIR}/#{zseed}"
  end

  # subdirs: `infos`, `chaps`, etc.
  def cache_dir(zseed : String, subdir : String)
    "#{CACHE_DIR}/#{zseed}/#{subdir}"
  end

  # fname: `1.html.gz`, `infos/4.json`, etc.
  def cache_file(zseed : String, fname : String)
    "#{CACHE_DIR}/#{zseed}/#{fname}"
  end

  # zseed: "hetushu", "jx_la", etc.
  def seeds_dir(zseed : String)
    "#{SEEDS_DIR}/#{zseed}"
  end

  # subdirs: `covers`, `intros`, etc.
  def seeds_dir(zseed : String, subdir : String)
    "#{SEEDS_DIR}/#{zseed}/#{subdir}"
  end

  # fname: `_index`, `status`, `genres`, etc.
  def seeds_map(zseed : String, fname : String)
    "#{SEEDS_DIR}/#{zseed}/#{fname}.tsv"
  end
end
