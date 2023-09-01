@[Flags]
enum WN::Chflag
  Htm # raw html is available (downloaded from remote sources)
  Raw # raw text is available (parse from htm or submitted by users)

  Con # raw text has silver/gold constituency
  Uzv # has custom translation submitted by users

  Tok # raw text has silver/gold tokenization
  Pos # raw text has silver/gold part-of-speech tagging

  Bzv # has translation from bing (from zh to vi)
  Gzv # has translation from google (from zh to vi)
end
