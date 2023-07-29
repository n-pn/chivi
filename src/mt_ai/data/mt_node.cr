require "./mt_opts"

class AI::MtNode
  # references:
  # - https://hanlp.hankcs.com/docs/annotations/pos/ctb.html
  # - https://hanlp.hankcs.com/docs/annotations/constituency/ctb.html

  property pos : String = "" # CTB
  property tag : String = "" # extra attributes

  property data : String | self | Array(self) = ""

  def translate(io : IO, opts : MtOpts)
  end

  # render tree as bracketed version (no newlines)
  def inspect(io : IO)
    io << '(' << @pos
    io << '-' << @tag unless @tag.empty?

    case data = @data
    in String
      io << ' ' << data
    in MtNode
      io << ' '
      data.inspect(io)
    in Array(MtNode)
      data.each { |node| io << ' '; node.inspect(io) }
    end

    io << ')'
  end

  # parsing bracketted string to data structure
  # FIXME: properly handle whitespaces in node contents
  # currently ignoring all whitespaces

  def self.from_str(str : String)
    queue = [] of MtNode

    acc_strio = String::Builder.new
    acc_empty = true

    str.each_char do |char|
      case char
      when '\n', '\t' then next
      when '('        then queue << MtNode.new
      when ' '
        next if acc_empty

        node = queue.last
        is_undef = node.pos.empty? # new node is not initialized, so the pos value is empty?

        unless is_undef
          acc_strio << char # allow whitespace inside raw string
          next
        end

        acc = acc_strio.to_s
        acc_strio = String::Builder.new
        acc_empty = true

        if is_undef
          node.pos, _, node.tag = acc.partition('-')
        else
          node.data = acc
        end
      when ')'
        unless acc_empty
          queue.last.data = acc_strio.to_s
          acc_strio = String::Builder.new
          acc_empty = true
        end

        break if queue.size == 1 # the only remain node is the TOP one

        child = queue.pop
        parent = queue.last

        case data = parent.data
        in Array(MtNode) then data << child
        in MtNode        then parent.data = [data, child]
        in String        then parent.data = child
        end
      else
        acc_strio << char
        acc_empty = false
      end
    end

    queue.first
  end
end
