class CV::UserPost
  include Clear::Model

  self.table = "user_posts"
  primary_key

  belongs_to viuser : Viuser, foreign_key_type: Int32
  belongs_to cvpost : Cvpost, foreign_key: "cvpost_id"

  column liked : Bool = false

  column last_rp_ii : Int32 = 0

  column atime : Int64 = 0_i64
  column utime : Int64 = 0_i64

  timestamps

  def mark!(atime = Time.utc.to_unix, last_rp_ii = 0)
    last_rp_ii = self.last_rp_ii if last_rp_ii < self.last_rp_ii
    update(atime: atime, last_rp_ii: last_rp_ii)
  end

  def set_liked!(value : Bool)
    update(liked: value, utime: Time.utc.to_unix)
  end

  ############

  def self.find_or_new(viuser_id : Int64, cvpost_id : Int64) : self
    params = {viuser_id: viuser_id, cvpost_id: cvpost_id}
    self.find(params) || self.new(params)
  end

  def self.find_or_new(viuser : Viuser, cvpost : Cvpost) : self
    self.find_or_new(viuser.id, cvpost.id)
  end

  def self.upsert!(viuser : Viuser, cvpost : Cvpost) : self
    user_post = find_or_new(viuser, cvpost)
    yield user_post
    user_post.save!
  end

  def self.upsert!(viuser_id : Int64, cvpost_id : Int64) : self
    user_post = find_or_new(viuser_id, cvpost_id)
    yield user_post
    user_post.save!
  end

  def self.glob(viuser : Viuser, cvpost_ids : Array(Int64))
    output = {} of Int64 => self
    return output if viuser.privi < 0

    self.query.where({viuser_id: viuser.id})
      .where { cvpost_id.in? cvpost_ids }
      .each { |x| output[x.cvpost_id] = x }

    output
  end
end
