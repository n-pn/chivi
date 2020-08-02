require "../../src/libcv/cv_repo"

repo = CvRepo.new("data/base_dicts")

puts repo.hanviet.size
puts repo.shared_base["generic"].time
puts repo.unique_base["not-found"].size
