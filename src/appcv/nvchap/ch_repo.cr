require "./ch_info"

class CV::ChRepo0
  getter data = Hash(Int16, ChInfo0).new(initial_capacity: 128)

  # forward_missing_to @data

  getter file : String

  def initialize(file : Path | String)
    @file = file.to_s
    load_file!(@file) if File.exists?(file)
  end

  def load_file!(file : String) : Nil
    File.read_lines(file).each do |line|
      cols = line.split('\t')
      next if cols.size < 3
      set(ChInfo0.new(cols))
    rescue err
      puts line.split('\t')
      puts err
    end
  end

  def values
    @data.values.sort_by!(&.chidx)
  end

  def get(chidx : Int16)
    @data[chidx]?
  end

  def set(chap : ChInfo0) : Nil
    @data[chap.chidx] = chap
  end

  def save!(file : String = @file)
    save!(file, self.values)
  end

  def save!(path : String, data : Array(ChInfo0))
    File.open(path, "w") { |io| data.join(io, '\n') }
  end

  #
  def self.pgidx(chidx : Int)
    (chidx &- 1) // 128
  end
end
