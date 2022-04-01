require "file_utils"
require "../shared/bootstrap"

cvpost_dir = "var/cvposts"
Dir.mkdir_p(cvpost_dir)

CV::Cvpost.query.order_by(id: :asc).each do |cvpost|
  File.write("#{cvpost_dir}/#{cvpost.id}.json", cvpost.to_pretty_json)
end

cvrepl_dir = "var/cvrepls"
Dir.mkdir_p(cvrepl_dir)
CV::Cvrepl.query.order_by(id: :asc).each do |cvrepl|
  File.write("#{cvrepl_dir}/#{cvrepl.id}.json", cvrepl.to_pretty_json)
end
