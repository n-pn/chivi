require "json"

class CV::Tlspec
  class Edit
    include JSON::Serializable

    property mtime = 0_i64

    property uname = ""
    property privi = 0

    property lower = 0
    property upper = 1

    property match = "" # spec type expected result/translation note
    property extra = "" # spec detail

    def initialize(user, @mtime = Time.utc.to_unix)
      @uname = user.uname
      @privi = user.privi
    end
  end

  getter file : String
  getter ukey : String

  property ztext = ""
  property dname = "" # vpdict dname (book slug)
  property d_dub = "" # vpdict label (book vi_name)
  property edits = [] of Edit

  def initialize(@ukey : String, fresh = false)
    @file = "#{DIR}/#{@ukey}.tsv"
    load!(@file) unless fresh
  end

  def load!(file : String) : Nil
    File.read_lines(@file).each do |line|
      type, data = line.split('\t', 2)

      case type
      when "ztext" then @ztext = data
      when "_dict" then @dname, @d_dub = data.split('\t', 2)
      else              @edits << Edit.from_json(data)
      end
    end
  end

  def add_edit!(form, viuser)
    edit = Tlspec::Edit.new(viuser)

    edit.lower = form.lower
    edit.upper = form.upper

    edit.match = form.match
    edit.extra = form.extra

    @edits << edit
  end

  def save!
    CACHE[@ukey] = self

    unless self.class.items.includes?(@ukey)
      self.class.items.unshift(@ukey)
    end

    File.open(@file, "w") do |io|
      io << "ztext" << "\t" << @ztext << "\n"
      io << "_dict" << "\t" << @dname << "\t" << @d_dub << "\n"

      @edits.each_with_index do |edit, idx|
        io << idx << "\t" << edit.to_json << "\n"
      end
    end
  end

  def delete! : Nil
    File.delete(@file)
    CACHE.delete(@ukey)
    self.class.items.delete(@ukey)
  end

  ######################

  CACHE = {} of String => self

  def self.load!(ukey : String) : self
    CACHE[ukey] ||= new(ukey)
  end

  class_getter items : Array(String) do
    files = Dir.glob("#{DIR}/*.tsv")
    files.sort_by! { |x| File.info(x).modification_time.to_unix.- }
    files.map { |x| File.basename(x, ".tsv") }
  end
end
