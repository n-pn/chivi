class CV::UserRepl
  include Clear::Model

  self.table = "user_repls"
  primary_key

  belongs_to cvuser : Cvuser, foreign_key: "cvuser_id"
  belongs_to cvrepl : Cvrepl, foreign_key: "cvrepl_id"

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

  def self.find_or_new(cvuser_id : Int64, cvrepl_id : Int64) : self
    params = {cvuser_id: cvuser_id, cvrepl_id: cvrepl_id}
    self.find(params) || self.new(params)
  end

  def self.find_or_new(cvuser : Cvuser, cvrepl : Cvrepl) : self
    self.find_or_new(cvuser.id, cvrepl.id)
  end

  def self.upsert!(cvuser : Cvuser, cvrepl : Cvrepl) : self
    user_repl = self.find_or_new(cvuser, cvrepl)
    yield user_repl
    user_repl.save!
  end

  def self.upsert!(cvuser_id : Int64, cvrepl_id : Int64) : self
    user_repl = self.find_or_new(cvuser_id, cvrepl_id)
    yield user_repl
    user_repl.save!
  end

  def self.glob(cvuser : Cvuser, cvrepl_ids : Array(Int64))
    output = {} of Int64 => self
    return output if cvuser.privi < 0

    result = self.query.where({cvuser_id: cvuser.id})
      .where { cvrepl_id.in? cvrepl_ids }
      .each { |x| output[x.cvrepl_id] = x }

    output
  end
end
