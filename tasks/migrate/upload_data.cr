INP_DIR = Path["var", "chtexts"]

Dir.children(INP_DIR).each do |sname|
  next unless sname.starts_with?('@') || sname == "users"

  system("rsync", [
    "-azi",
    "--no-p",
    "--delete",
    INP_DIR.join(sname).to_s,
    "nipin@ssh.chivi.app:srv/chivi/var/chtexts",
  ])
end