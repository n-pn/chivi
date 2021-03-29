require "./shared/*"

class Hanviet
  HANZIDB = QtDict.load("_system/hanzidb.txt")

  TRADSIM = CV::Vdict.tradsim
  BINH_AM = CV::Vdict.binh_am

  getter input : QtDict = QtDict.load("_autogen/hanviet.txt", false)

  def merge!(file : String, mode = :old_first)
    QtDict.load(file).each do |key, vals|
      QtUtil.lexicon.add(key)

      next if key =~ /\P{Han}/
      @input.set(key, vals, mode)
    end
  end

  def gen_from_trad!
    TRADSIM.each do |term|
      next if term.key.size > 0
      next unless vals = @input[term.key]?

      term.vals.each do |simp|
        next if @input.has_key?(simp)
        @input.set(simp, vals)
      end
    end
  end

  def save!
    hanviet_file = "_db/dictdb/active/system/hanviet.tsv"
    File.delete(hanviet_file) if File.exists?(hanviet_file)

    output = CV::Vdict.load("hanviet", reset: true)

    input = @input.to_a.sort_by(&.[0].size)
    input.each do |(key, vals)|
      next if key.size > 4
      next unless first = vals.first?

      if key.size > 1
        convert = QtUtil.convert(output, key, " ")
        next if first == convert
        pp [key, vals, convert]
      end

      output.set(key, vals.uniq.first(3))
    end

    remote = CV::Vdict.new("_db/dictdb/remote/system/hanviet.tsv", 2_i8, 3_i8)
    remote.logs.each do |term|
      output.set(term) unless term.power < 3
    end

    output.save!(prune: true)
  end
end

task = Hanviet.new

task.merge!("localqt/hanviet.txt")
task.merge!("hanviet/lacviet-chars.txt")
task.merge!("hanviet/lacviet-words.txt")

task.merge!("hanviet/trichdan-chars.txt")
task.merge!("hanviet/trichdan-words.txt")

task.merge!("hanviet/verified-chars.txt", mode: :keep_new)
task.merge!("hanviet/verified-words.txt", mode: :keep_new)

task.merge!("hanviet/correct-chars.txt", mode: :keep_new)

task.gen_from_trad!
task.save!

QtUtil.lexicon.save!
