require "file_utils"
require "../shared/bootstrap"

dtopic_dir = "var/dtopics"
Dir.mkdir_p(dtopic_dir)

CV::Cvpost.query.order_by(id: :asc).each do |dtopic|
  File.write("#{dtopic_dir}/#{dtopic.id}.json", dtopic.to_pretty_json)
end

dtpost_dir = "var/dtposts"
Dir.mkdir_p(dtpost_dir)
CV::Cvrepl.query.order_by(id: :asc).each do |dtpost|
  File.write("#{dtpost_dir}/#{dtpost.id}.json", dtpost.to_pretty_json)
end
