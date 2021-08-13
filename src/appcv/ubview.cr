class CV::Ubview
  include Clear::Model

  self.table = "ubviews"
  primary_key

  belongs_to cvbook : Cvbook
  belongs_to cvuser : Cvuser

  column bumped : Int64 = 0_i64 # order field

  column zseed : Int32 = 0
  column chidx : Int32 = 0

  getter sname : String { Zhseed.sname(zseed) }

  column ch_title : String = ""
  column ch_label : String = ""
  column ch_uslug : String = ""

  def self.migrate!(cvuser : Cvuser)
    ViMark.chap_map(cvuser.uname.downcase).each do |bhash, vals|
      next unless cvbook = Cvbook.find({bhash: bhash})
      bumped, sname, chidx, title, uslug = vals

      Ubview.new({
        cvbook: cvbook, cvuser: cvuser,
        zseed: Zhseed.index(sname),
        chidx: chidx, ch_title: title, ch_uslug: uslug,
      }).save
    end
  end

  def self.upsert!(cvuser : Cvuser, cvbook : Cvbook)
    model = find({cvuser_id: cvuser.id, cvbook_id: cvbook.id})
    model ||= new({cvuser: cvuser, cvbook: cvbook})

    yield model
    model.save!
  end
end
