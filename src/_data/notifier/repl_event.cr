require "./_notif_base"

module CV::Notifier
  def on_repl_event(repl : Rpnode)
    return if repl.touser_id == 0 || repl.touser_id == repl.viuser_id
    return if Unotif.find(:get_replied, repl.id, repl.viuser_id)

    rproot = Rproot.find!(id: repl.rproot_id)
    byuser = Viuser.get_uname(id: repl.viuser_id)

    kind = Rproot::Kind.new(rproot.kind)
    if repl.torepl_id > 0
      context = "phản hồi bình luận của bạn trong #{kind.vstr}"
    else
      context = "thêm bình luận mới trong #{kind.vstr}"
    end

    content = <<-HTML
      <p><a href="/@#{byuser}" class="cv-user">#{byuser}</a> đã #{context}
      <a href="#{rproot._link}#r#{repl.id}">#{rproot._name}</a>.</p>
      HTML

    Unotif.new(
      viuser_id: repl.touser_id, content: content,
      action: :get_replied, object_id: repl.id, byuser_id: repl.viuser_id,
      created_at: repl.created_at
    ).create!
  end

  private def reply_action(rproot : Rproot, is_repl = false)
    case kind
    when .dtopic? then "thêm bình luận mới trong chủ đề bạn tạo"
    when .vicrit? then "thêm bình luận mới trong đánh giá truyện của bạn"
    when .vilist? then "thêm bình luận mới trong thư đơn của bạn"
    when .viuser? then "thêm bình luận mới trên trang cá nhân của bạn"
    else               "thêm bình luận mới trong #{kind.vstr}"
    end
  end

  ####

  def on_user_tagged_in_reply(repl : Rpnode)
    return if repl.tagged_ids.empty?

    rproot = Rproot.find!(id: repl.rproot_id)
    byuser = Viuser.get_uname(id: repl.viuser_id)

    link_to = "#{rproot._link}#r#{repl.id}"
    content = <<-HTML
      <p><a href="/@#{byuser}" class="cv-user">#{byuser}</a> đã nhắc đến tên bạn
      tại một bài viết trong #{rproot._type} <a href="#{link_to}">#{rproot._name}</a>.</p>
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
end
