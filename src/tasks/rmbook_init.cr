require "../zroot/rmbook"

def init(sname : String)
  db = ZR::Rmbook.db(sname)

  (0..).each do |block|
    lower = block &* 1000
    upper = lower &+ 999

    inputs = PG_DB::Rmbook.query.where("id >= #{lower} and id <= #{upper}").to_a
    puts "- block: #{block}, books: #{inputs.size}"

    break if inputs.empty?

    db.exec "begin"

    inputs.each do |input|
      entry = ZR::Rmbook.new(input.id)

      entry.upsert!(db)
    end

    db.exec "commit"
  end
end
