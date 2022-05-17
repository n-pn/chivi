require "log"
require "colorize"
require "file_utils"

require "./vp_dict/*"

class CV::VpDict
  enum Kind
    Basic; Novel; Theme; Cvmtl; Other
  end

  enum Mode
    Full # preload both main file (.tsv) and user file (.tab)
    Main # only preload main file
    None # do not preload any existing files
  end

  DIR = "var/vpdicts/v1"

  class_getter hanviet : self { load_other("hanviet") }
  class_getter surname : self { load_other("surname") }

  class_getter pin_yin : self { load_other("pin_yin") }
  class_getter tradsim : self { load_other("tradsim") }

  class_getter essence : self { load_basic("essence") }
  class_getter regular : self { load_basic("regular") }
  class_getter fixture : self { load_basic("fixture") }

  class_getter combine : self { load_basic("combine") }
  class_getter suggest : self { load_basic("suggest") }

  class_getter nvdicts : Array(String) do
    files = Dir.glob("#{DIR}/novel/*.tsv")
    files.map! { |f| File.basename(f, ".tsv") }
  end

  class_getter qtdicts : Array(String) do
    files = Dir.glob("#{DIR}/libcv/*.tsv")
    files.map { |f| "~" + File.basename(f, ".tsv") }
  end

  NOVEL = {} of String => self
  THEME = {} of String => self
  FIXED = {} of String => self

  def self.load_novel(dname : String, mode : Mode = :full) : self
    NOVEL[dname] ||= new(path(dname, "novel"), kind: :novel, type: 3, mode: mode)
  end

  def self.load_theme(dname : String, mode : Mode = :full) : self
    THEME[dname] ||= new(path(dname, "thêm"), kind: :theme, type: 2, mode: mode)
  end

  def self.load_cvmtl(dname : String, mode : Mode = :full) : self
    FIXED[dname] ||= new(path(dname, "cvmtl"), kind: :cvmtl, type: 1, mode: mode)
  end

  def self.load_other(dname : String, mode : Mode = :full) : self
    FIXED[dname] ||= new(path(dname, "other"), kind: :other, type: 0, mode: mode)
  end

  def self.load_basic(dname : String, mode : Mode = :full) : self
    case dname
    when "essence", "fixture"
      FIXED[dname] ||= new(path(dname, "basic"), kind: :basic, type: 1, mode: mode)
    when "regular"
      FIXED[dname] ||= new(path(dname, "basic"), kind: :basic, type: 2, mode: mode)
    else # for combine type
      FIXED[dname] ||= new(path(dname, "basic"), kind: :basic, type: 3, mode: mode)
    end
  end

  def self.load(dname : String, mode : Mode = :full) : self
    case dname[0]?
    when '-' then load_novel(dname[1..], mode: mode)
    when '!' then load_theme(dname[1..], mode: mode)
    when '~' then load_cvmtl(dname[1..], mode: mode)
    when '$' then load_other(dname[1..], mode: mode)
    else          load_basic(dname, mode: mode)
    end
  end

  def self.path(label : String, group : String = ".")
    File.join(DIR, group, label + ".tsv")
  end

  #########################

  getter file : String
  getter flog : String

  getter trie = VpTrie.new
  getter list = [] of VpTerm

  getter kind : Kind
  getter type = 1 # dict type
  getter size = 0

  # forward_missing_to @list
  delegate scan, to: @trie

  # mode
  # -1: ignore existing dict file
  # 0: load existing dict file if exists
  # 1: load log file
  def initialize(@file : String, @kind : Kind = :basic, @type = 1, mode : Mode = :full)
    @flog = @file.sub(".tsv", ".tab") # log file path
    return if mode.none?

    load!(@file) if File.exists?(@file)
    load!(@flog) if mode.full? && File.exists?(@flog)
  end

  def load!(file : String = @file) : Nil
    lines = File.read_lines(file)
    lines.each do |line|
      set(VpTerm.new(line.split('\t'), dtype: @type))
    rescue err
      Log.error { "<vp_dict> [#{file}] error on `#{line}`: #{err}]".colorize.red }
    end

    # Log.info { "<vp_dict> [#{file.sub(DIR, "")}] loaded: #{lines.size} lines".colorize.green }
  end

  def find(key : String | Array(Char)) : VpTerm?
    @trie.find(key).try(&.base)
  end

  def find(key : String, uname : String) : Tuple(VpTerm?, VpTerm?)
    return {nil, nil} unless node = @trie.find(key)
    {node.base, node.privs[uname]?}
  end

  def set(key : String, vals : Array(String), attr = "")
    set(VpTerm.new(key, vals, attr, mtime: 0))
  end

  def set(term : VpTerm) : VpTerm?
    @list << term
    return unless @trie.find!(term.key).push!(term)
    @size += 1 if term.state == "Thêm"
    term
  end

  def set!(term : VpTerm) : VpTerm?
    return unless set(term)

    # File.open(@file, "a") { |io| io << '\n'; term.to_s(io, dtype: @type) }
    File.open(@flog, "a") { |io| io << '\n'; term.to_s(io, dtype: @type) }

    term
  end

  # set prune level
  # 1: delete overwritten entries
  # 2: delete shadowed entries (update in under 5 minutes)
  # 3: do not delete anything

  def save!(file = @file, prune : Int8 = 2_u8, save_log = false) : Nil
    return if prune < 1

    data = @list.reject { |x| x.key.empty? || x._flag >= prune }
    do_save!(@file, data) if data.size > 0

    return unless save_log

    logs = data.select(&.mtime.> 0)
    do_save!(@flog, logs) if logs.size > 0
  end

  private def do_save!(file : String, list : Array(VpTerm))
    return if list.empty?
    list.sort_by! { |x| {x.mtime, x.key.size, x.key} }

    data = String.build do |io|
      list.each_with_index do |term, i|
        io << "\n" unless i == 0
        term.to_s(io, dtype: @type)
      end
    end

    File.write(file, data)
    Log.info { "<vp_dict> [#{file.sub(DIR, "")}] saved, items: #{list.size}".colorize.yellow }
  end
end
