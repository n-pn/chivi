class QT::CharDict
  DIR = "var/dicts/qtran/%{name}-chars.tsv"

  def self.load(name : String)
    new(DIR % {name: name})
  end

  @data = {} of Char => String

  def initialize(file : String)
    load_file!(file)
  end

  def load_file!(file : String)
    File.each_line(file) do |line|
      args = line.split('\t')
      next unless key = args[0]?
      # next if key.size > 1

      char = key[0]
      val = args[1]?

      if val
        @data[char] = val
      else
        @data.delete(char)
      end
    end
  end

  def find(char : Char)
    @data[char]?
  end
end
