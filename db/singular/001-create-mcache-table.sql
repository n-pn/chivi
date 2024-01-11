DROP TABLE IF EXISTS mcache;

CREATE TABLE mcache(
  rid bigint NOT NULL,
  ver smallint NOT NULL,
  tid int NOT NULL,
  --
  tok text[] NOT NULL DEFAULT '{}',
  con jsonb NOT NULL DEFAULT '[]',
  dep text NOT NULL DEFAULT '',
  ner text NOT NULL DEFAULT '',
  pos text[] NOT NULL DEFAULT '{}',
  --
  mtime int NOT NULL DEFAULT 0,
  --
  PRIMARY KEY (rid, ver, tid)
);
