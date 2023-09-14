require "./qt_node"

class MT::QtData < Array(MT::QtNode)
  def to_txt(cap : Bool = true, und : Bool = true) : String
    String.build { |io| to_txt(io, cap, und) }
  end

  def to_txt(io : IO, cap : Bool = true, und : Bool = true)
    each { |node| cap, und = node.to_txt(io, cap, und) }
  end

  def to_mtl(cap : Bool = true, und : Bool = true) : String
    String.build { |io| to_mtl(io, cap, und) }
  end

  def to_mtl(io : IO, cap : Bool = true, und : Bool = true)
    each { |node| cap, und = node.to_mtl(io, cap, und) }
  end

  # include JSON::Serializable

  def to_json : Nil
    JSON.build { |jb| to_json(jb) }
  end

  def to_json(io : IO) : Nil
    JSON.build(io) { |jb| to_json(jb) }
  end

  def to_json(jb : JSON::Builder) : Nil
    jb.array do
      jb.string "TOP"
      jb.number 0
      jb.number self.sum(&.zstr.size)
      jb.string ""

      jb.array do
        self.each { |node| node.to_json(jb) }
      end
    end
  end
end
