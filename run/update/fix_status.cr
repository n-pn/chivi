# require "./shared/seed_util"

# class CV::FixStatus
#   FRESH = (Time.utc - 3.years).to_unix

#   def set!
#     total, index = Wninfo.query.count, 0
#     query = Wninfo.query.order_by(weight: :desc)
#     query.each_with_cursor(20) do |nvinfo|
#       index += 1
#       puts "- [fix_status] <#{index}/#{total}>".colorize.blue if index % 100 == 0

#       status = nvinfo.status
#       if status == 0 && nvinfo.utime < FRESH
#         status = 3
#         nvinfo.update!({status: status})
#       end

#       nvinfo.nvseeds.each do |nvseed|
#         next if nvseed.status == status
#         nvseed.update!({status: status})
#         puts "#{nvseed.sname}/#{nvseed.snvid} updated status to #{status}"
#       end
#     end
#   end
# end

# worker = CV::FixStatus.new
# worker.set!
