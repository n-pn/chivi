require "../../src/_data/notifier/*"

def fetch_all(action : CV::Unotif::Action)
  CV::Unotif.db.query_all <<-SQL, action.value, as: CV::Unotif
  select * from unotifs where "action" = $1
  SQL
end

def fix_dtopic_liking_notif
  unotifs = fetch_all(:like_dtopic)

  unotifs.each do |unotif|
    byuser = CV::Viuser.get_uname(unotif.byuser_id)
    target = CV::Dtopic.load!(id: unotif.object_id)

    content = CV::Notifier.render_content(byuser) do |html|
      html << "thích " << CV::Notifier.liking_content(target)
    end

    puts unotif.content.colorize.blue
    puts content.colorize.green

    CV::Unotif.db.exec <<-SQL, content, unotif.id
    update unotifs set content = $1 where id = $2
  SQL
  end
end

def fix_vicrit_liking_notif
  unotifs = fetch_all(:like_vicrit)

  unotifs.each do |unotif|
    byuser = CV::Viuser.get_uname(unotif.byuser_id)

    target = CV::Vicrit.load!(id: unotif.object_id)

    content = CV::Notifier.render_content(byuser) do |html|
      html << "thích " << CV::Notifier.liking_content(target)
    end

    puts unotif.content.colorize.blue
    puts content.colorize.green

    CV::Unotif.db.exec <<-SQL, content, unotif.id
    update unotifs set content = $1 where id = $2
  SQL
  end
end

def fix_gdrepl_liking_notif
  unotifs = fetch_all(:like_gdrepl)

  unotifs.each do |unotif|
    gdrepl = CV::Gdrepl.load!(id: unotif.object_id)
    puts unotif.content.colorize.blue

    byuser = CV::Viuser.get_uname(unotif.byuser_id)

    content = CV::Notifier.render_content(byuser) do |html|
      html << "thích " << CV::Notifier.liking_content(gdrepl)
    end

    puts content.colorize.green

    CV::Unotif.db.exec <<-SQL, content, unotif.id
    update unotifs set content = $1 where id = $2
  SQL
  end
end

def fix_direct_reply_notif
  unotifs = fetch_all(:get_replied)

  unotifs.each do |unotif|
    puts unotif.content.colorize.blue

    gdrepl = CV::Gdrepl.load!(id: unotif.object_id)
    gdroot = CV::Gdroot.find!(id: gdrepl.gdroot_id)
    byuser = CV::Viuser.get_uname(unotif.byuser_id)

    content = CV::Notifier.render_content(byuser) do |html|
      if gdrepl.torepl_id > 0
        html << <<-HTML
          <a href="#{gdroot.gdrepl_link(gdrepl.id)}">phản hồi bình luận</a> của bạn
          trong #{gdroot.thread_type} <a href="#{gdroot.origin_link}">#{gdroot.oname}</a>.
        HTML
      else
        html << <<-HTML
        <a href="#{gdroot.gdrepl_link(gdrepl.id)}">thêm bình luận mới</a>
        trong #{gdroot.thread_type} <a href="#{gdroot.origin_link}">#{gdroot.oname}</a> của bạn.
        HTML
      end
    end

    puts content.colorize.green

    CV::Unotif.db.exec <<-SQL, content, unotif.id
      update unotifs set content = $1 where id = $2
    SQL
  end
end

fix_gdrepl_liking_notif
fix_dtopic_liking_notif
fix_vicrit_liking_notif
# fix_direct_reply_notif
