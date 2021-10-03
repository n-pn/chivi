require "./shared/seed_util"

class CV::FixStatus
  MFTIME = (Time.utc - 3.years).to_unix

  def fix!
    total, index = Cvbook.query.count, 0
    query = Cvbook.query.order_by(weight: :desc)
    query.each_with_cursor(20) do |cvbook|
      index += 1
      puts "- [fix_status] <#{index}/#{total}>".colorize.blue if index % 100 == 0

      status = cvbook.status
      if status == 0 && cvbook.mftime < MFTIME
        status = 3
        cvbook.update!({status: status})
      end

      cvbook.zhbooks.each do |zhbook|
        next if zhbook.status == status
        zhbook.update!({status: status})
        puts "#{zhbook.sname}/#{zhbook.snvid} updated status to #{status}"
      end
    end
  end
end

worker = CV::FixStatus.new
worker.fix!
