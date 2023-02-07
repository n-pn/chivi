require "./_shared"

module Split
  def self.split_1(input : Array(String))
    chaps = [] of Array(String)
    lines = [] of String

    empty_count = 0

    input.each do |line|
      line = line.tr("　", " ").strip

      if line.empty?
        empty_count += 1
        next
      end

      if empty_count > 1 && !lines.empty?
        chaps << lines
        lines = [] of String
      end

      empty_count = 0
      lines << line
    end

    chaps << lines unless lines.empty?

    chaps
  end
end
