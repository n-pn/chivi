require "../shared/seed_util"

CV::Yscrit.query.order_by(id: :asc).with_nvinfo.each_with_cursor(10) do |yscrit|
  vhtml = CV::SeedUtil.cv_ztext(yscrit.zhtext, yscrit.nvinfo.bhash)
  yscrit.update!({vhtml: vhtml})
end
