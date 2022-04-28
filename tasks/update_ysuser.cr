require "./shared/bootstrap"

CV::Ysuser.query.each do |ysuser|
  ysuser.tap(&.fix_name).save!
end
