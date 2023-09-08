require "sqlite3"

DB.open("sqlite3:var/mt_v2/dicts/ud211-data.db") do |db|
  db.exec <<-SQL
    create table if not exists terms(
      line integer,
      lpos integer,

      word varchar, -- Word form or punctuation symbol.
      viet varchar default '',

      upos varchar default '', -- Universal part-of-speech tag: https://universaldependencies.org/u/pos/index.html
      ptag varchar default '', -- Language-specific part-of-speech tag; underscore if not available.

      feats varchar default '_', -- List of morphological features from the universal feature inventory or from a defined language-specific extension; underscore if not available.
      head integer default 0, -- Head of the current word, which is either a value of ID or zero (0).
      deprel varchar, -- Universal dependency relation to the HEAD (root iff HEAD = 0) or a defined language-specific subtype of one.
      deps varchar default '_', -- Enhanced dependency graph in the form of a list of head-deprel pairs.
      misc varchar default '', -- Any other annotation.
      primary key (line, lpos)
    )
  SQL

  db.exec "create index if not exists terms_word_idx on terms(word);"
  db.exec "create index if not exists terms_ptag_idx on terms(ptag);"
end

DB.open("sqlite3:var/mt_v2/dicts/ud211-freq.db") do |db|
  db.exec <<-SQL
    create table if not exists freqs(
      word varchar,
      viet varchar,
      ptag varchar,
      freq integer default 0,
      primary key (word, ptag)
    )
  SQL

  db.exec "create index if not exists freqs_ptag_idx on freqs(ptag);"
end
