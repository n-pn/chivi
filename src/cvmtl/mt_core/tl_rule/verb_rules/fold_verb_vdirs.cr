module CV::TlRule
  def fold_verb_vdirs!(verb : MtNode, vdir : MtNode) : MtNode
    if verb.verb? && vdir.key == "过去"
      if (succ = vdir.succ?)
        if succ.ude1? && (noun = scan_noun!(succ.succ?))
          if noun.human?
            vdir.set!("đi qua", PosTag::Vintr)
          else
            vdir.set!("quá khứ", PosTag::Noun)
          end

          node = fold_ude1_left!(succ, vdir, noun)
          return fold!(verb, node, PosTag::VerbObject, dic: 6)
        end

        if noun = scan_noun!(succ)
          verb = fold!(verb, vdir.set!("qua"), PosTag::Verb, dic: 5)
          return fold!(verb, noun, PosTag::VerbObject, dic: 6)
        end
      end

      vdir.set!("quá khứ", PosTag::Noun)
      return fold!(verb, vdir, PosTag::VerbObject, dic: 6)
    end

    case vdir.key
    when "起"  then vdir.val = "lên"
    when "进"  then vdir.val = "vào"
    when "来"  then vdir.val = "tới"
    when "过去" then vdir.val = "qua"
    when "下去" then vdir.val = "xuống"
    when "下来" then vdir.val = "lại"
    when "起来" then vdir.val = "lên"
    end

    fold!(verb, vdir, PosTag::Verb, dic: 5)
  end
end
