require "./ch_info"

class CV::ChList
  getter data = Hash(Int32, ChInfo).new(initial_capacity: 128)

  # forward_missing_to @data

  def initialize(@file : String, reset : Bool = false)
    load_file!(@file) if !reset && File.exists?(file)
  end

  def load_file!(file : String)
    File.read_lines(file).each do |line|
      store(ChInfo.new(line.split('\t'))) unless line.empty?
    rescue err
      puts line.split('\t')
    end
  end

  def get(chidx : Int32)
    @data[chidx]? || ChInfo.new(chidx)
  end

  def store!(chap : ChInfo) : Nil
    store(chap)
    File.open(@file, "a") { |io| io << '\n' << chap }
  end

  def store(chap : ChInfo) : Bool
    if prev = @data[chap.chidx]?
      changed = prev.changed?(chap)
      chap.inherit!(prev)
    else
      changed = true
    end

    @data[chap.chidx] = chap
    changed
  end

  def patch(list : Array(ChInfo))
    list.each { |chap| self.store(chap) }
  end

  def trans!(cvmtl : MtCode)
    @data.each_value(&.trans!(cvmtl))
  end

  def save!(file : String = @file)
    ChList.save!(file, @data.values.sort_by!(&.chidx))
  end

  #######################

  def self.save!(file : String, infos : Array(ChInfo), mode = "w")
    File.open(file, mode) do |io|
      io << '\n' if mode == "a"
      infos.each { |x| io << x << '\n' }
    end
  end
end
