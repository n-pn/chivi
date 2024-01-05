DROP TABLE IF EXISTS vcache;

CREATE TABLE vcache(
  rid bigint NOT NULL,
  obj smallint NOT NULL,
  vid int NOT NULL,
  val text NOT NULL,
  mcv int NOT NULL DEFAULT 0,
  PRIMARY KEY (rid, obj, vid)
);
