CREATE TABLE IF NOT EXISTS defns(
  zstr varchar PRIMARY KEY, -- raw string
  vstr varchar NOT NULL DEFAULT '', -- translation
  --
  cv_ner varchar NOT NULL DEFAULT '', -- result from chivi own ner engine
  ts_sdk varchar NOT NULL DEFAULT '', -- texsmart offline sdk
  ts_acc varchar NOT NULL DEFAULT '', -- texsmart high accurate
  --
  uname varchar NOT NULL DEFAULT '', -- last modified by this user
  mtime bigint NOT NULL DEFAULT 0, -- last modified time
  _flag smallint NOT NULL DEFAULT 0 -- lock/track field
);
