require "./_models"
require "./author"
require "./btitle"
require "./bgenre"
require "../../shared/core_utils"

# Book info
class Chivi::Serial
  include Clear::Model
  self.table = "serials"

  primary_key type: :serial
  timestamps

  column zh_slug : String
  column hv_slug : String
  column vi_slug : String?

  belongs_to author : Author, foreign_key_type: Int32
  belongs_to btitle : Btitle, foreign_key_type: Int32

  column bgenre_ids : Array(Int32), presence: false
  column vi_bgenres : Array(String), presence: false

  column zh_intro : String?
  column vi_intro : String?
  column intro_by : String? # source name

  column hidden : Int32, presence: false
  column status : Int32, presence: false

  column update_at : Int64, presence: false
  column access_at : Int64, presence: false

  column zh_voters : Int32, presence: false   # seed voters (yousuu or custom)
  column zh_rating : Float32, presence: false # seed rating (yousuu or custom)

  column vi_voters : Int32, presence: false   # chivi genuine voters
  column vi_rating : Float32, presence: false # chivi genuine rating

  column word_count : Int32, presence: false
  column chap_count : Int32, presence: false

  column view_count : Int32, presence: false
  column read_count : Int32, presence: false

  column review_count : Int32, presence: false
  column follow_count : Int32, presence: false

  column popularity : Int32, presence: false # to be sorted by

  column cover_name : String?
  column yousuu_bid : String?
  column origin_url : String?

  def fix_popularity
    zh_score = Math.log(zh_voters) * zh_rating
    vi_score = Math.log(vi_voters) * vi_rating

    self.popularity = (zh_score + vi_score).*(100).round.to_i
    self
  end

  def set_bgenre(zh_genre : String)
    bgenres = Bgenre.upsert_all!(zh_genre)

    ids = bgenre_ids_column.value([] of Int32)
    self.bgenre_ids = ids.concat(bgenres.map(&.id))

    names = vi_bgenres_column.value([] of String)
    self.vi_bgenres = names.concat(bgenres.map(&.vi_name))

    self
  end

  def fix_hv_slug!(slug : String? = nil)
    slug = short_slug(self.hv_slug) unless slug

    if slug != self.hv_slug
      begin
        self.hv_slug = slug
        save!
      rescue
        self.hv_slug_column.revert
      end
    end
  end

  def fix_vi_slug!(slug : String? = nil)
    return unless slug || vi_slug_column.value(nil)
    slug = short_slug(self.vi_slug.not_nil!) unless slug

    unless slug.empty? || slug == self.vi_slug
      begin
        self.vi_slug = slug
        save!
      rescue
        self.vi_slug_column.revert
      end
    end
  end

  def short_slug(slug : String)
    slug.sub(/-#{self.zh_slug}$/, "")
  end

  def set_intro(zh_intro : Array(String), intro_by : String)
    self.zh_intro = zh_intro.join("\n")
    self.intro_by = intro_by

    mtl = Convert.content(zh_slug) # TODO: change to hv_slug
    self.vi_intro = zh_intro.map { |line| mtl.cv_plain(line).to_text }.join("\n")
  end

  def self.find(author : Author, btitle : Btitle)
    find({author_id: author.id, btitle_id: btitle.id})
  end

  def self.upsert!(zh_author : String, zh_btitle : String) : self
    author = Author.upsert!(zh_author)
    btitle = Btitle.upsert!(zh_btitle)

    unless model = find(author, btitle)
      model = new({author_id: author.id, btitle_id: btitle.id})

      # TODO: replace `--` with `  `
      zh_slug = CoreUtils.digest32("#{btitle}--#{author}")
      hv_slug = btitle.hv_name_tsv.join("-")
      vi_slug = btitle.vi_name_tsv.join("-")

      model.zh_slug = zh_slug
      model.hv_slug = "#{hv_slug}-#{zh_slug}"
      model.vi_slug = "#{vi_slug}-#{zh_slug}" unless vi_slug.empty?

      model.save!
    end

    model.tap do |x|
      x.fix_hv_slug!
      x.fix_vi_slug!
    end
  end
end
