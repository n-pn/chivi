require "./shared/seed_util"

class CV::FixStatus
  MFTIME = (Time.utc - 3.years).to_unix

  def set!
    total, index = Nvinfo.query.count, 0
    query = Nvinfo.query.order_by(weight: :desc)
    query.each_with_cursor(20) do |nvinfo|
      index += 1
      puts "- [fix_status] <#{index}/#{total}>".colorize.blue if index % 100 == 0

      status = nvinfo.status
      if status == 0 && nvinfo.utime < MFTIME
        status = 3
        nvinfo.update!({status: status})
      end

      nvinfo.zhbooks.each do |zhbook|
        next if zhbook.status == status
        zhbook.update!({status: status})
        puts "#{zhbook.sname}/#{zhbook.snvid} updated status to #{status}"
      end
    end
  end
end

worker = CV::FixStatus.new
worker.set!
