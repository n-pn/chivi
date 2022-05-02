require "../shared/bootstrap"

module CV::FixIntros
  extend self

  DEBUG = ARGV.includes?("--debug")

  def fix_intro!(nvinfo : Nvinfo, redo = false)
    unless redo || nvinfo.cvseed.bintro.empty?
      bintro = nvinfo.cvseed.bintro.split("\n")
      return nvinfo.update(bintro: BookUtil.cv_lines(bintro, nvinfo.dname, :text))
    end

    yintro = nil
    nvinfo.ysbook.try { |x| yintro = x.bintro.split(/\n|\t/) }

    bintro = sname = nil
    nvinfo.nvseeds.to_a.sort(&.zseed.-).each do |nvseed|
      sintro = nvseed.bintro.split(/\n|\t/)
      next if sintro.empty? || !decent?(nvseed.sname, sintro, yintro)

      bintro = sintro
      sname = nvseed.sname
      break
    end

    if sname != "users" && yintro && yintro.size > 1
      bintro = yintro
    end

    return unless bintro ||= yintro

    if DEBUG
      title = "#{nvinfo.bslug}\t#{nvinfo.bhash}\n"
      File.write("tmp/fix-intro.log", "#{title}\n#{bintro.join('\n')}")
    end

    nvinfo.set_bintro(bintro, force: true)
  end

  private def decent?(sname : String, bintro : Array(String), yintro : Array(String)?)
    case sname
    when "users", "staff"     then true
    when "hetushu", "zhwenpg" then !bintro.empty?
    else
      return false if bintro.empty?
      yintro ? yintro.includes?(bintro[0]) : bintro.size > 1
    end
  end

  def fix_all!
    redo = ARGV.includes?("--redo")
    count = 0

    Nvinfo.query.order_by(weight: :desc).each do |nvinfo|
      count += 1
      puts "- <#{count}> #{nvinfo.bslug}" if count % 1000 == 0
      fix_intro!(nvinfo, redo: redo)
    end
  end

  fix_all!
end
