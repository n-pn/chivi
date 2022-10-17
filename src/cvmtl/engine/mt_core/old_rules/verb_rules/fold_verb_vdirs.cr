module MT::TlRule
  # ameba:disable Metrics/CyclomaticComplexity
  def fold_verb_vdirs!(verb : MtNode, vdir : MtNode) : MtNode
    if verb.verb? && vdir.key == "过去"
      if (succ = vdir.succ?)
        # puts [verb, vdir, succ]
        if succ.pt_dep? && (noun = scan_noun!(succ.succ?))
          vdir.set!("quá khứ", PosTag::Tword)
          node = fold_ude1_left!(ude1: succ, left: vdir, right: noun)
          return fold!(verb, node, PosTag::Vobj)
        end

        if noun = scan_noun!(succ)
          verb = fold!(verb, vdir.set!("qua"), PosTag::Verb)
          return fold!(verb, noun, PosTag::Vobj)
        end
      end

      vdir.set!("quá khứ", PosTag::Tword)
      return fold!(verb, vdir, PosTag::Vobj)
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

    return verb if vdir.succ?(&.verb_words?) && verb.ends_with?('了')
    fold!(verb, vdir, PosTag::Verb)
  end
end