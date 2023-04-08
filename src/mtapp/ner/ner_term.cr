require "./ent_mark"

class MT::NerTerm
  getter bner = EntMark::None # mark begin
  getter iner = EntMark::None # mark intermediate
  getter ener = EntMark::None # mark end
  getter sner = EntMark::None # mark single

  getter defs = {} of EntMark => String # translation if avaiable

  def initialize(marks : Enumerable(String), trans : String)
    @bner, @iner, @ener, @sner = EntMark.extract(marks)

    trans.split('\t').each do |entry|
      defn, mark = entry.split('ǀ', 2)
      mark = EntMark.parse?(mark) || ""
    end
  end
end
