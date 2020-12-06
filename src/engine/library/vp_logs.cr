require "./vp_dict/vp_term"

class Chivi::VpLogs
  SEP_0 = 'ǀ'
  SEP_1 = '¦'

  class Entry
    property dic : String = ""
    property key : String = ""

    property vals : String = ""
    property olds : String = ""

    property mtime : Int32 = 0
    property uname : String = ""
    property plock : Int32 = 1

    property prevail : Bool = false
    property context : String = ""

    def initialize
    end

    def initialize(@dic, new_term : VpTerm, old_term : VpTerm?, @prevail : Bool, @context = "")
      @key = new_term.key

      @vals = render_vals(new_term)
      @olds = render_vals(old_term) if old_term

      @mtime = new_term.mtime
      @uname = new_term.uname
      @plock = new_term.plock

      e.context = context
      e.prevail = prevail
    end

    def render_vals(term : VpTerm)
      {term.vals.join(SEP_0), term.attr}.join(SEP_1)
    end

    def println(io : IO)
      {key, vals, olds, mtime, uname, plock, prevail ? 'A' : 'D', context}.join(io, '\t')
      io << '\n'
    end

    def self.parse(line : String, dict : String)
      cols = line.split('\t')

      new.tap do |e|
        e.dic = dict
        e.key = cols[0]

        e.vals = cols[1]? || ""
        e.olds = cols[2]? || ""

        e.mtime = cols[3]?.try(&.to_i?) || 0
        e.uname = cols[4]? || "<init>"
        e.plock = cols[5]?.try(&.to_i?) || 1

        e.prevail = cols[6]? == 'A'
        e.context = cols[7]? || ""
      end
    end
  end

  getter entries = [] of Entry

  getter dics_idx = Hash(String, Array(Entry)).new { |h, k| h[k] = [] of Entry }
  getter keys_idx = Hash(String, Array(Entry)).new { |h, k| h[k] = [] of Entry }
  getter user_idx = Hash(String, Array(Entry)).new { |h, k| h[k] = [] of Entry }

  def initialize(@dir : String)
    Dir.glob("#{@dir}/**/*.tab").each { |file| load(file) }
  end

  def load(file : String)
    label = File.basename(file, ".tab")

    File.each_line(file) do |line|
      line = line.strip
      next if line.empty?

      insert(Entry.from(line, label))
    end
  end

  def insert!(file : String, entry : Entry) : Nil
    File.open(file, "a") { |io| entry.println(io) }
    insert(entry)
  end

  def insert(entry : Entry) : Nil
    @entries << entry

    @dics_idx[entry.dic] << entry
    @keys_idx[entry.key] << entry
    @user_idx[entry.uname] << entry
  end
end
