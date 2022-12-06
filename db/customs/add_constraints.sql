ALTER TABLE ubmemos
  ADD CONSTRAINT ubmemos_viuser_id_fkey FOREIGN KEY (viuser_id) REFERENCES viusers (id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE cvposts
  ADD CONSTRAINT cvposts_viuser_id_fkey FOREIGN KEY (viuser_id) REFERENCES viusers (id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE cvrepls
  ADD CONSTRAINT cvrepls_viuser_id_fkey FOREIGN KEY (viuser_id) REFERENCES viusers (id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE user_posts
  ADD CONSTRAINT user_posts_viuser_id_fkey FOREIGN KEY (viuser_id) REFERENCES viusers (id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE user_repls
  ADD CONSTRAINT user_repls_viuser_id_fkey FOREIGN KEY (viuser_id) REFERENCES viusers (id) ON UPDATE CASCADE ON DELETE CASCADE;

-- ALTER TABLE chap_edits
--   ADD CONSTRAINT chap_edits_viuser_id_fkey FOREIGN KEY (viuser_id) REFERENCES viusers (id) ON UPDATE CASCADE ON DELETE CASCADE;
