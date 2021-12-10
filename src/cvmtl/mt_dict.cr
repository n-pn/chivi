require "log"
require "./vp_dict/vp_term"

class CV::MtDict
  SEP = "ǀ"
  DIR = "var/vpdicts/cvmtl"

  REFINE_NOUNS = new("#{DIR}/refine-nouns.tsv")
  REFINE_VERBS = new("#{DIR}/refine-verbs.tsv")
  REFINE_ADJTS = new("#{DIR}/refine-adjts.tsv")

  QUANTI_NOUNS = new("#{DIR}/quanti-nouns.tsv")
  QUANTI_TIMES = new("#{DIR}/quanti-times.tsv")
  QUANTI_VERBS = new("#{DIR}/quanti-verbs.tsv")

  U_ZHI_RIGHTS = new("#{DIR}/u_zhi-rights.tsv")

  VERBS_2_OBJECTS = new("#{DIR}/verbs-2-objects.tsv")
  VERBS_SEPERATED = new("#{DIR}/verbs-seperated.tsv")

  getter list = [] of VpTerm
  getter hash = {} of String => VpTerm
  getter vals = {} of String => String?

  forward_missing_to @vals

  @file : String
  @ftab : String

  def initialize(@file)
    @ftab = @file.sub(".tsv", ".tab")
    load!(@file)
    load!(@ftab) if File.exists?(@ftab)
  end

  def load!(file : String)
    File.read_lines(file).each do |line|
      term = VpTerm.new(line.split('\t'))
      set(term)
    rescue err
      Log.error { err.message }
    end
  end

  def set!(term : VpTerm) : Nil
    set(term).try do
      File.open(@ftab, "a") { |io| io << "\n"; term.to_s(io) }
    end
  end

  def set(term : VpTerm) : VpTerm?
    return unless newer?(term, @hash[term.key]?)
    @list << term

    unless term.is_priv
      @hash[term.key] = term

      if val = term.val.first?.try { |x| x unless x.empty? }
        @vals[term.key] = val
      else
        @vals.delete(term.key)
      end
    end

    term
  end

  # checking if new term can overwrite current term
  private def newer?(term : VpTerm, prev : VpTerm?)
    return true unless prev
    # do not record if term is outdated
    return false if term.mtime < prev.mtime

    if term.uname == prev.uname
      prev._flag = 2_u8
      term._prev = prev._prev
    else
      prev._flag = 1_u8
      term._prev = prev
    end

    false
  end
end
