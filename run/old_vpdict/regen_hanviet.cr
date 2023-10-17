require "./shared/*"

class Hanviet
  HANZIDB = QtDict.load("system/hanzidb.txt")

  TRADSIM = CV::VpDict.tradsim
  PIN_YIN = CV::VpDict.pin_yin

  getter input : QtDict = QtDict.load(".temps/hanviet.txt", false)

  def merge!(file : String, mode = :old_first)
    QtDict.load(file, preload: true).each do |key, vals|
      QtUtil.lexicon.add(key)

      next if key =~ /\P{Han}/
      @input.set(key, vals, mode)
    end
  end

  def gen_from_trad!
    TRADSIM.list.each do |term|
      next if term.key.size > 0
      next unless vals = @input.data[term.key]?

      term.val.each do |simp|
        next if @input.has_key?(simp)
        @input.set(simp, vals)
      end
    end
  end

  def add_custom!
    @input.set("苹", ["tần"], :keep_new)
  end

  def save!
    output = CV::VpDict.load("$hanviet", mode: :reset)

    input = @input.to_a.sort_by(&.[0].size)
    input.each do |(key, vals)|
      next if output.find(key)
      # next if key.size > 4
      next unless first = vals.first?

      if key.size > 1
        convert = QtUtil.convert(output, key, " ")
        next if first == convert
        puts [key, vals, convert]
      end

      output.set(key, vals.uniq.first(3))
    end

    output.load!("var/vpdicts/v1/basic/hanviet.tab")

    File.each_line("var/vpdicts/v1/_init/patch/hanviet.tsv") do |line|
      next if line.empty?

      new_term = CV::VpTerm.new(line.split('\t'))

      if old_term = output.find(new_term.key)
        old_term.force_fix!(new_term.val)
      else
        output.set(new_term)
      end
    end

    output.save!(prune: 1)
  end
end

task = Hanviet.new

task.merge!("qtrans/localqt/hanviet.txt")
task.merge!("qtrans/hanviet/lacviet-chars.txt")
task.merge!("qtrans/hanviet/lacviet-words.txt")

task.merge!("qtrans/hanviet/trichdan-chars.txt")
task.merge!("qtrans/hanviet/trichdan-words.txt")

task.merge!("qtrans/hanviet/verified-chars.txt", mode: :keep_new)
task.merge!("qtrans/hanviet/verified-words.txt", mode: :keep_new)

task.merge!("qtrans/hanviet/correct-chars.txt", mode: :keep_new)

task.gen_from_trad!
task.add_custom!
task.save!

QtUtil.lexicon.save!
