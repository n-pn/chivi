require "../../src/ysweb/models/*"

Clear::SQL.transaction do
  crits = YS::Yscrit.query.where("ysbook_id = 0")
    .select("id", "nvinfo_id", "ysuser_id").to_a
  puts "missing: #{crits.size}"

  crits.each do |crit|
    # next unless ysbook = CV::Ysbook.find({nvinfo_id: crit.nvinfo_id})
    next unless ysbook_id = crit.nvinfo.ysbook_id

    puts "#{crit.id} => #{ysbook_id}"

    crit.ysbook_id = ysbook_id
    crit.save!
  end
end
