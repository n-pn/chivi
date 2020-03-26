module CvCore
  def fix_grammar(input : Tokens) : Tokens
    output = Tokens.new
    idx = 0

    # TODO: handle more special rules, like:
    # - convert hanzi to number,
    # - convert hanzi percent
    # - date and time
    # - guess special words meaning..
    # - apply `的` grammar
    # - apply other grammar rule
    # - ...

    while idx < input.size
      token = input[idx]
      jdx = idx + 1

      if token.key == "的"
        token.val = ""
        token.dic = 0
      end

      output << token
      idx = jdx
    end

    output
  end
end
