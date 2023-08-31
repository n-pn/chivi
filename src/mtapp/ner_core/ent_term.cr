require "../data/entities"

class MT::EntTerm
  getter bner = EntMark::None # mark begin
  getter iner = EntMark::None # mark intermediate
  getter ener = EntMark::None # mark end
  getter sner = EntMark::None # mark single

  getter vstr : String # translation if avaiable

  def initialize(marks : Enumerable(String), @vstr)
    @bner = @iner = @ener = @sner = EntMark::None

    marks.each do |entry|
      mark, _, type = entry.partition('-')

      mark = EntMark.parse?(mark) || EntMark::None
      type = "BIES" if type.empty?

      type.each_char do |char|
        case char
        when 'B' then @bner |= mark
        when 'I' then @iner |= mark
        when 'E' then @ener |= mark
        when 'S' then @sner |= mark
        end
      end
    end
  end
end
