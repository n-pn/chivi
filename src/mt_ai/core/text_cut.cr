module MT::TextCut
  def self.split_ztext(ztext : String, h_sep = 1, l_sep = 0)
    body = [] of Array(Array(String | MtNode))
  end

  def self.split_heads(line : String, &) : Nil
  end

  END_CHARS = {'。', '！', '？', '：'}

  NEST_OPNS = {'“', '〈', '（'}
  NEST_ENDS = {'”', '〉', '）'}

  def self.split_sents(line : String, &) : Nil
    sbuf = String::Builder.new
    from = 0
    upto = 0

    was_end = 0 # 0: not end, 2: full end, 1: semi end, after need to be `“`
    on_nest = -1

    line.each_char do |char|
      upto &+= 1

      if on_nest >= 0
        on_nest = -1 if NEST_ENDS.index(char) == on_nest
        was_end = 0
        sbuf << char
        next
      end
      LineSeg
      if char == '”'
        sbuf << char
        next
      end

      if char.in?(END_CHARS)
        was_end = char == '：' ? 1 : 2
        sbuf << char
        next
      end

      if was_end > 1 || (was_end == 1 && char == '“')
        yield sbuf.to_s, from
        sbuf = String::Builder.new
        from = upto &- 1
      end

      sbuf << char
      was_end = 0

      on_nest = NEST_OPNS.index(char) || -1
      on_nest = -1 if on_nest == 0 && (line == 0 || !line[from &- 1].in?(END_CHARS))
    end

    if from < upto
      yield sbuf.to_s, from
    end
  end

  # test = "“问到了，在那条巷子里面。”安知鱼将自己饮料放在了车前的篮子里面，然后让白可卿上了车，载着她往前面骑了过去。"
  # test = "“直接就问到了吗？”白可卿有些吃惊，她还以为得花上一番功夫才能找到黑网吧呢。"
  # test = "“那当然。”安知鱼笑着说道：“你男朋友出马，马到成功。”"
  # puts test

  # split_sents test do |sent, from|
  #   puts [sent, from, sent.size]
  # end
end
