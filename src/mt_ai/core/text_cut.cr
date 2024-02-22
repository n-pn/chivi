require "./mt_rule/*"
require "./mt_util/*"

module MT::TextCut
  def self.split_ztext(ztext : String, h_sep = 1, l_sep = 0)
    bases = [] of {MtNode, Array(MtNode)}
    texts = [] of String
    l_ids = [] of Int32

    ztext.each_line.with_index do |line, l_id|
      body = [] of MtNode
      node = MtNode.new(body: body, zstr: line, epos: :TOP, from: 0)
      bases << {node, body}

      if l_id < h_sep
        title, split = TlChap.split(line)
        body << split if split
        texts << title
        l_ids << l_id
      else
        split_sents(line) do |frag|
          texts << frag
          l_ids << l_id
        end
      end
    end

    {bases, texts, l_ids}
  end

  def self.split_heads(line : String, &) : Nil
    yield line
    # TODO: call split title here
  end

  END_CHARS = {'。', '！', '？', '：', '…'}

  NEST_OPNS = {'“', '〈', '（'}
  NEST_ENDS = {'”', '〉', '）'}

  def self.split_sents(line : String, &) : Nil
    sbuf = String::Builder.new
    from = 0
    upto = 0

    was_end = 0 # 0: not end, 1: full end, 2: semi end, after need to be `“`
    on_nest = -1

    line.each_char do |char|
      upto &+= 1

      if on_nest >= 0
        on_nest = -1 if NEST_ENDS.index(char) == on_nest
        was_end = 0
        sbuf << char
        next
      end

      if char == '”'
        sbuf << char
        next
      end

      if char.in?(END_CHARS)
        was_end = char == '：' ? 2 : 1
        sbuf << char
        next
      end

      if was_end == 1 || (was_end == 2 && char == '“')
        yield sbuf.to_s
        sbuf = String::Builder.new
        from = upto &- 1
      end

      sbuf << char
      was_end = 0

      on_nest = NEST_OPNS.index(char) || -1
      on_nest = -1 if on_nest == 0 && (line == 0 || !line[from &- 1].in?(END_CHARS))
    end

    yield sbuf.to_s if from < upto
  end

  # test = "“问到了，在那条巷子里面。”安知鱼将自己饮料放在了车前的篮子里面，然后让白可卿上了车，载着她往前面骑了过去。"
  # test = "“直接就问到了吗？”白可卿有些吃惊，她还以为得花上一番功夫才能找到黑网吧呢。"
  # test = "“那当然。”安知鱼笑着说道：“你男朋友出马，马到成功。”"
  # test = "“呼，原来是幻听啊……”男子攥紧拳头，小声说，“我高似锦无论如何，都要再度回家才行……”"
  # puts test

  # test = "“其它卫兵呢？法师们呢？”"
  # split_sents(test) do |sent|
  #   puts sent
  # end

  #
end
