require "./**"

module CV::Notifier
  extend self

  def on_liking_target(target, memoir : Memoir, byuser : String)
    action = Unotif::Action.map_liking(target)
    return if Unotif.find(action, target.id, memoir.viuser_id)

    Unotif.new(
      viuser_id: target.viuser_id, content: liking_content(target, byuser),
      action: action, object_id: target.id, byuser_id: memoir.viuser_id,
      created_at: Time.unix(memoir.liked_at)
    ).create!
  end

  private def liking_content(target : Rpnode, byuser : String) : String
    rproot = Rproot.find!(id: target.muhead_id)
    <<-HTML
    <p><a href="/@#{byuser}" class="cv-user">#{byuser}</a> đã thích bài viết của bạn
    trong #{rproot._type} <a href="#{rproot._link}#r#{target.id}">#{rproot._name}</a>.</p>
    HTML
  end

  private def liking_content(target : Dtopic, byuser : String)
    <<-HTML
    <p><a href="/@#{byuser}" class="cv-user">#{byuser}</a> đã thích chủ đề
    <a href="/gd/t-#{target.id}-#{target.tslug}">#{target.title}</a> của bạn.</p>
    HTML
  end

  private def liking_content(target : Vicrit, byuser : String)
    <<-HTML
    <p><a href="/@#{byuser}" class="cv-user">#{byuser}</a> đã thích
    <a href="/uc/v#{target.id}">đánh giá truyện</a> của bạn.</p>
    HTML
  end

  private def liking_content(target : Vilist, byuser : String)
    <<-HTML
    <p><a href="/@#{byuser}" class="cv-user">#{byuser}</a> đã thích
    <a href="/ul/v#{target.id}-#{target.tslug}">thư đơn</a> của bạn.</p>
    HTML
  end

  def on_unliking_target(target, memoir : Memoir)
    action = Unotif::Action.map_liking(target)
    Unotif.remove_notif(action, target.id, memoir.viuser_id)
  end

  ###############

  def on_user_making_reply(repl : Rpnode)
    return if repl.touser_id == 0 || repl.touser_id == repl.viuser_id
    return if Unotif.find(:get_replied, repl.id, repl.viuser_id)

    rproot = Rproot.find!(id: repl.muhead_id)
    byuser = Viuser.get_uname(id: repl.viuser_id)

    action = reply_action(rproot, prev_is_repl: repl.torepl_id > 0)

    link_to = "#{rproot._link}#r#{repl.id}"
    content = <<-HTML
      <p><a href="/@#{byuser}" class="cv-user">#{byuser}</a> đã #{action}
      <a href="#{link_to}">#{rproot._name}</a>.</p>
      HTML

    Unotif.new(
      viuser_id: repl.touser_id, content: content,
      action: :get_replied, object_id: repl.id, byuser_id: repl.viuser_id,
      created_at: repl.created_at
    ).create!
  end

  private def reply_action(rproot : Rproot, prev_is_repl = false)
    case
    when prev_is_repl
      "phản hồi bình luận của bạn trong #{rproot._type}"
    when rproot.urn.starts_with?("gd")
      "thêm bình luận mới trong chủ đề bạn tạo"
    when rproot.urn.starts_with?("vc")
      "thêm bình luận mới trong đánh giá truyện của bạn"
    when rproot.urn.starts_with?("vl")
      "thêm bình luận mới trong thư đơn của bạn"
    when rproot.urn.starts_with?("vu")
      "thêm bình luận mới trên trang cá nhân của bạn"
    else
      "thêm bình luận mới trong #{rproot._type}"
    end
  end

  ####

  def on_user_tagged_in_reply(repl : Rpnode)
    return if repl.tagged_ids.empty?

    muhead = Rproot.find!(id: repl.muhead_id)
    byuser = Viuser.get_uname(id: repl.viuser_id)

    link_to = "#{muhead._link}#r#{repl.id}"
    content = <<-HTML
      <p><a href="/@#{byuser}" class="cv-user">#{byuser}</a> đã nhắc đến tên bạn
      tại một bài viết trong #{muhead._type} <a href="#{link_to}">#{muhead._name}</a>.</p>
    HTML

    repl.tagged_ids.each do |tagged_id|
      next if tagged_id == repl.touser_id || tagged_id == repl.viuser_id
      return if Unotif.find(:tagged_in_reply, repl.id, repl.viuser_id)

      Unotif.new(
        viuser_id: tagged_id, content: content,
        action: :tagged_in_reply, object_id: repl.id, byuser_id: repl.viuser_id,
        created_at: repl.created_at
      ).create!
    end
  end

  ###
end
