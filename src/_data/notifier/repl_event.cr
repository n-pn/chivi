require "./_notif_base"

module CV::Notifier
  def on_repl_event(gdrepl : Rpnode)
    gdroot = Gdroot.find!(id: gdrepl.gdroot_id)
    byuser = Viuser.get_uname(id: gdrepl.viuser_id)

    reached = Set{gdrepl.viuser_id}

    if gdrepl.touser_id == 0 || gdrepl.touser_id == gdrepl.viuser_id
      # do nothing if sender == target
    elsif Unotif.find(:get_replied, gdrepl.id, gdrepl.viuser_id)
      # do nothing if notif created
    else
      reached = on_reply_directly(gdrepl, gdroot, byuser, reached)
    end

    _reached = on_tagged_in_reply(gdrepl, gdroot, byuser, reached)
  end

  def on_reply_directly(
    gdrepl : Rpnode,
    gdroot = Gdroot.find!(id: gdrepl.gdroot_id),
    byuser = Viuser.get_uname(id: gdrepl.viuser_id),
    reached = Set{gdrepl.viuser_id, gdrepl.touser_id}
  ) : Set(Int32)
    content = render_content(byuser) do |html|
      html << (gdrepl.torepl_id > 0 ? "phản hồi bình luận của bạn" : "thêm bình luận mới")
      html << <<-HTML
       trong #{gdroot.thread_type} <a href="#{gdroot.gdrepl_link(gdrepl.id)}">#{gdroot.oname}</a>
      HTML
    end

    targets = Set{gdrepl.touser_id}
    targets << 1 << 2 if gdrepl.touser_id < 8 # add to admin accounts

    targets.each do |target_id|
      reached << target_id

      Unotif.new(
        viuser_id: target_id, content: content,
        action: :get_replied, object_id: gdrepl.id, byuser_id: gdrepl.viuser_id,
        created_at: gdrepl.created_at
      ).create!
    end

    reached
  end

  ####

  def on_tagged_in_reply(
    gdrepl : Rpnode,
    gdroot = Gdroot.find!(id: gdrepl.gdroot_id),
    byuser = Viuser.get_uname(id: gdrepl.viuser_id),
    reached = Set{gdrepl.viuser_id, gdrepl.touser_id}
  )
    tagged_ids = gdrepl.tagged_ids.reject(&.in?(reached))
    return reached if tagged_ids.empty?

    content = render_content(byuser) do |html|
      html << <<-HTML
        đã nhắc đến tên bạn tại một bài viết trong #{gdroot.thread_type}
        <a href="#{gdroot.gdrepl_link(gdrepl.id)}">#{gdroot.oname}</a>.</p>
        HTML
    end

    tagged_ids << 1 << 2 if tagged_ids.any?(&.< 8)
    tagged_ids.each do |tagged_id|
      reached << tagged_id
      next if Unotif.find(:tagged_in_reply, gdrepl.id, gdrepl.viuser_id)

      Unotif.new(
        viuser_id: tagged_id, content: content,
        action: :tagged_in_reply, object_id: gdrepl.id, byuser_id: gdrepl.viuser_id,
        created_at: gdrepl.created_at
      ).create!
    end

    reached
  end
end
