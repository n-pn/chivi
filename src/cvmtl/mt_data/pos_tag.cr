require "log"
require "yaml"

module MT::PosTag
  @[Flags]
  enum Attr
    Void # for word that marked empty

    NoSpaceL # no space before
    NoSpaceR # no space after

    CapRelay # relay capitalization
    CapAfter # add capitalizion after this node

    def self.parse(array : Array(String))
      array.reduce(None) { |memo, attr| memo | parse(attr) }
    end

    def self.init(apply_cap : Bool = true)
      apply_cap ? self.flags(CapAfter, NoSpaceR) : NoSpaceR
    end
  end

  struct Entry
    include YAML::Serializable

    getter ptag : String
    getter extd = [] of String
    getter attr = [] of String

    # getter name : String
    # getter desc : String = ""
  end

  PTAG_STR = {} of Int32 => String

  TAG_HASH = {} of String => Int32
  TAG_ATTR = {} of Int32 => Attr
  ROLE_MAP = {} of Int32 => Array(Int32)

  files = Dir.glob("var/cvmtl/ptags/*.yml")
  files.sort_by! { |x| File.basename(x, ".yml").split('-').first.to_i }

  files.each do |file|
    File.open(file, "r") do |io|
      Array(Entry).from_yaml(io).each do |entry|
        ptag = map_tag(entry.ptag)
        TAG_ATTR[ptag] = Attr.parse(entry.attr)

        roles = entry.extd.each_with_object([ptag]) do |extd, memo|
          next unless extd_roles = ROLE_MAP[map_tag(extd)]?
          memo.concat(extd_roles)
        end

        ROLE_MAP[ptag] = roles.uniq!
      end
    end
  rescue err
    Log.error(exception: err) { file }
  end

  Tymd = map_tag("Tymd")
  Thms = map_tag("Thms")

  Mcar = map_tag("Mcar")
  Mdig = map_tag("Mdig")
  Mlit = map_tag("Mlit")

  Mdeci = map_tag("Mdeci")
  Mfrac = map_tag("Mfrac")
  Mprox = map_tag("Mprox")

  ZLink = map_tag("Z_link")
  ZMail = map_tag("Z_mail")
  ZMoji = map_tag("Z_moji")
  ZUnkn = map_tag("Z_unkn")

  Zblank = map_tag("Zblank")

  Extr = map_tag("Extr")
  Noth = map_tag("Noth")

  def self.number?(tag : Int32)
    {Mcar, Mdig, Mlit, Mdeci, Mfrac, Mprox}.includes?(tag)
  end

  def self.map_tag(str : String)
    TAG_HASH[str] ||= (TAG_HASH.size &+ 1).tap { |x| PTAG_STR[x] = str }
  end

  def self.tag_str(tag : Int32)
    PTAG_STR[tag]? || "N/A"
  end

  def self.tag_str(tag : Array(Int32))
    tag.map { |x| tag_str(x) }
  end

  def self.attr_of(tag : Int32)
    TAG_ATTR[tag]? || Attr::None
  end

  # puts TAG_HASH, ROLE_MAP
  # puts EXTD_MAP.to_a.max_by(&.[1].size)
  # puts TAG_HASH.find { |k, v| v == 39 }

  # puts ROLE_MAP[map_tag("Ndir")].map { |x| tag_str(x) }
  # puts ROLE_MAP[map_tag("Prep_cong")].map { |x| tag_str(x) }
end
