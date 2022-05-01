require "../shared/bootstrap"

CV::Nvinfo.query.each do |nvinfo|
  utimes = nvinfo.nvseeds.to_a.reject(&.in?(0, 63)).map(&.utime)
  nvinfo.update(utime: utimes.max) unless utimes.empty?
end
