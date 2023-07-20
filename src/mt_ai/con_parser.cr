class Node
  property pos : String = ""
  property tag : String = ""
  property data : String | self | Array(self) = ""

  def inspect(io : IO)
    io << '(' << @pos
    io << '-' << @tag unless @tag.empty?

    case data = @data
    in String
      io << ' ' << data
    in Node
      io << ' '
      data.inspect(io)
    in Array(Node)
      data.each { |node| io << ' '; node.inspect(io) }
    end

    io << ')'
  end
end

def parse_con_str(str : String)
  output = [] of Node

  acc_strio = String::Builder.new
  acc_empty = true

  str.each_char do |char|
    # pp char
    case char
    when '\n', '\t' then next
    when '('        then output << Node.new
    when ' '
      next if acc_empty

      node = output.last
      is_undef = node.pos.empty?

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
        output.last.data = acc_strio.to_s
        acc_strio = String::Builder.new
        acc_empty = true
      end

      break if output.size == 1
      child = output.pop
      parent = output.last

      case data = parent.data
      in Array(Node) then data << child
      in Node        then parent.data = [data, child]
      in String      then parent.data = child
      end
    else
      acc_strio << char
      acc_empty = false
    end
  end

  output.first
end

TXT1 = <<-TXT
(TOP (IP (IP (NP-PN-SBJ (NR 路易斯·布努埃尔))
	  (VP (VC 是)
	      (NP-PRD (QP (CD 一)
			  (CLP (M 位)))
		      (NP-PN (NR 西班牙))
		      (NP (NN 超现实主义者)))))
      (PU ，)
      (IP (NP-SBJ (DNP (NP (PN 他))
		       (DEG 的))
		  (NP (NN 电影)))
	  (VP (VV 包括)
	      (UCP-OBJ (NP-PN (PU 《))
		       (NP (DNP (NP-PN (NR 安达鲁))
				(DEG 之))
			   (NP (NN 犬)))
		       (PU 》)
		       (PRN (PU （)
			    (IP (NP-LOC (NN 里面))
				(NP-SBJ-1 (NN 眼球))
				(VP (SB 被)
				    (VP (VV 割开)
					(NP-OBJ (-NONE- *-1)))))
			    (PU ）))
		       (PU 、)
		       (NP-PN (PU 《))
		       (NP (NN 黄金)
			   (NN 时代))
		       (PU 》)
		       (PU 、)
		       (NP-PN (PU 《))
		       (DNP (NP (NN 资产阶级))
			    (DEG 的))
		       (ADJP (JJ 审慎))
		       (NP (NN 魅力))
		       (PU 》)
		       (PU 、)
		       (NP-PN (PU 《))
		       (NN 女仆)
		       (NN 日记)
		       (PU 》)
		       (PU 、)
		       (NP-PN (PU 《))
		       (ADJP (JJ 毁灭))
		       (NP (NN 天使))
		       (PU 》)
		       (PU 、)
		       (NP-PN (PU 《))
		       (DNP (LCP (NP (NN 沙漠))
				 (LC 中))
			    (DEG 的))
		       (NP-PN (NR 西蒙))
		       (PU 》)
		       (CC 以及)
		       (NP (QP (CD 一)
			       (CLP (M 部)))
			   (DNP (PP (P 关于)
				    (NP (NP-PN (NR 基督))
					(NP (NN 一生))))
				(DEG 的))
			   (NP (NN 电影))))))
      (PU 。)
      (IP (LCP-LOC (NP (QP (DT 这)
			   (CLP (M 部)))
		       (NP (NN 电影)))
		   (LC 里))
	  (VP (VE 有)
	      (NP-OBJ (QP (CD 一)
			  (CLP (M 个)))
		      (DNP (ADJP (JJ 有趣))
			   (DEG 的))
		      (NP (NN 细节)))))
      (PU ，)
      (IP (NP-PN-SBJ (NR 基督))
	  (VP (VP (VSB (VV 跑步)
		       (VV 去)))
	      (VP (VV 听)
		  (NP-OBJ (DNP (NP (NN 山上))
			       (DEG 的))
			  (NP (NN 布道)))))
	  (PU ，)
	  (PP-PRP (P 因为)
		  (CP (IP (NP-SBJ (PN 他))
			  (VP (VV 迟到)))
		      (SP 了))))
      (PU 。)))
TXT

TXT2 = <<-TXT
(TOP (IP (NP-PN-SBJ (NR 布赖恩·Ｍ·帕普斯克))
      (VP (VV 撰写))))
TXT
pp parse_con_str(TXT1)
