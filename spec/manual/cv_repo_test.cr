require "../../src/engine/cv_repo"

repo = Engine::CvRepo.new("data/dic-out")

puts repo.system.get_dic("hanviet").size
puts repo.common.get_dic("generic").mtime
puts repo.unique["not-found"][0].size
