ALTER TABLE rdmemos
  ADD COLUMN rmode text NOT NULL DEFAULT 'qt',
  ADD COLUMN mt_rm text NOT NULL DEFAULT 'mtl_1',
  ADD COLUMN qt_rm text NOT NULL DEFAULT 'qt_v1',
  ADD COLUMN lc_mtype smallint NOT NULL DEFAULT 0,
  ADD COLUMN lc_title text NOT NULL DEFAULT '',
  ADD COLUMN lc_ch_no int NOT NULL DEFAULT 0,
  ADD COLUMN lc_p_idx smallint NOT NULL DEFAULT 1;
