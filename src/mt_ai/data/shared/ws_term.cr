require "./mt_ener"

struct MT::WsTerm
  getter zstr : String
  getter prio : Int16

  getter bner : MtEner = :none
  getter iner : MtEner = :none
  getter oner : MtEner = :none

  def self.calc_prio(size : Int32, prio : Int16 = 3_i16)
    prio == 0 ? 0_i16 : size.to_i16 &* (prio &+ size.to_i16)
  end

  def initialize(@zstr,
                 @prio = WsTerm.calc_prio(zstr.size),
                 @bner = :none, @iner = :none, @oner = :none)
  end

  def initialize(cols : Array(String))
    @zstr = cols[0]
    @prio = WsTerm.calc_prio(zstr.size, cols[1]?.try(&.to_i16?) || 3_i16)

    return unless ners = cols[2]?

    ners.split(' ').each do |xner|
      head, _, tail = xner.partition('-')
      ener = MtEner.parse(head)

      if tail.empty?
        @bner |= ener
        @iner |= ener
      else
        tail.each_char do |char|
          case char
          when 'B' then @bner |= ener
          when 'I' then @iner |= ener
          when 'O' then @oner |= ener
          end
        end
      end
    end
  end

  def inspect(io : IO) : Nil
    ners = Hash(MtEner, Array(Char)).new { |h, k| h[k] = [] of Char }

    MtEner.each do |ner|
      ners[ner] << 'B' if @bner.includes?(ner)
      ners[ner] << 'I' if @iner.includes?(ner)
      ners[ner] << 'O' if @oner.includes?(ner)
    end

    io << @zstr << '\t' << @prio << '\t'
    ners.each do |ner, chars|
      io << ner << '-' << chars.join << ' '
    end
  end

  delegate size, to: @zstr
end
