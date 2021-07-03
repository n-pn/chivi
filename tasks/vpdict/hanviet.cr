require "./shared/*"

class Hanviet
  HANZIDB = QtDict.load("system/hanzidb.txt")

  TRADSIM = CV::Vdict.tradsim
  BINH_AM = CV::Vdict.binh_am

  getter input : QtDict = QtDict.load(".temps/hanviet.txt", false)

  def merge!(file : String, mode = :old_first)
    QtDict.load(file, preload: true).each do |key, vals|
      QtUtil.lexicon.add(key)

      next if key =~ /\P{Han}/
      @input.set(key, vals, mode)
    end
  end

  def gen_from_trad!
    TRADSIM.each do |term|
      next if term.key.size > 0
      next unless vals = @input.data[term.key]?

      term.vals.each do |simp|
        next if @input.has_key?(simp)
        @input.set(simp, vals)
      end
    end
  end

  def add_custom!
    @input.set("苹", ["tần"], :keep_new)
  end

  def save!
    output = CV::Vdict.load("hanviet", reset: true)

    input = @input.to_a.sort_by(&.[0].size)
    input.each do |(key, vals)|
      # next if key.size > 4
      next unless first = vals.first?

      if key.size > 1
        convert = QtUtil.convert(output, key, " ")
        next if first == convert
        pp [key, vals, convert]
      end

      output.set(key, vals.uniq.first(3))
    end

    remote = CV::Vdict.new("_db/vp_dicts/backup/system/hanviet.tsv", 2, 3)
    remote.logs.each do |term|
      output.set(term) unless term.power < 3
    end

    output.save!(prune: true)
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
