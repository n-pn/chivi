require "./ent_mark"

class MT::EntTerm
  getter bner = EntMark::None # mark begin
  getter iner = EntMark::None # mark intermediate
  getter ener = EntMark::None # mark end
  getter sner = EntMark::None # mark single

  getter vals = {} of EntMark => String # translation if avaiable

  def initialize(marks : Enumerable(String), trans : Enumerable(String))
    @bner = @iner = @ener = @sner = EntMark::None

    marks.each do |entry|
      mark, _, type = entry.partition('-')

      mark = EntMark.parse(mark)
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

    trans.each do |entry|
      val, _, mark = entry.partition('ǀ')
      mark = EntMark.parse?(mark) || EntMark::None
      @vals[mark] = val
    end
  end

  @[AlwaysInline]
  def get_val(mark : EntMark)
    @vals[mark]? || @vals.first_value
  end
end
