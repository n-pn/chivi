class CV::UserPost
  include Clear::Model

  self.table = "user_posts"
  primary_key

  belongs_to cvuser : Cvuser, foreign_key: "cvuser_id"
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

  def self.find_or_new(cvuser_id : Int64, cvpost_id : Int64) : self
    params = {cvuser_id: cvuser_id, cvpost_id: cvpost_id}
    self.find(params) || self.new(params)
  end

  def self.find_or_new(cvuser : Cvuser, cvpost : Cvpost) : self
    self.find_or_new(cvuser.id, cvpost.id)
  end

  def self.upsert!(cvuser : Cvuser, cvpost : Cvpost) : self
    user_post = find_or_new(cvuser, cvpost)
    yield user_post
    user_post.save!
  end

  def self.upsert!(cvuser_id : Int64, cvpost_id : Int64) : self
    user_post = find_or_new(cvuser_id, cvpost_id)
    yield user_post
    user_post.save!
  end

  def self.glob(cvuser : Cvuser, cvpost_ids : Array(Int64))
    output = {} of Int64 => self
    return output if cvuser.privi < 0

    result = self.query.where({cvuser_id: cvuser.id})
      .where { cvpost_id.in? cvpost_ids }
      .each { |x| output[x.cvpost_id] = x }

    output
  end
end
