require "./_notif_base"

module CV::Notifier
  def on_like_event(target, memoir : Memoir, byuser : String)
    return if target.viuser_id == memoir.viuser_id

    action = Unotif::Action.map_liking(target)
    return if Unotif.find(action, target.id.as(Int32), memoir.viuser_id)

    content = render_content(byuser) do |html|
      html << "thích " << liking_content(target)
    end

    output = Unotif.new(
      viuser_id: target.viuser_id, content: content,
      action: action, object_id: target.id.as(Int32), byuser_id: memoir.viuser_id,
      created_at: Time.unix(memoir.liked_at)
    )

    output.insert!
  end

  def liking_content(target : Gdrepl) : String
    gdroot = Gdroot.find_by_id!(id: target.gdroot_id)
    <<-HTML
    <a href="#{gdroot.gdrepl_link(target.id)}">bài viết của bạn</a>
    trong #{gdroot.thread_type} <a href="#{gdroot.origin_link}">#{gdroot.oname}</a>.</p>
    HTML
  end

  def liking_content(target : Dtopic)
    <<-HTML
    chủ đề <a href="#{target.canonical_path}">#{target.title}</a> của bạn.
    HTML
  end

  def liking_content(target : Vicrit)
    <<-HTML
    <a href="#{target.canonical_path}">đánh giá truyện</a> của bạn.
    HTML
  end

  def liking_content(target : Vilist)
    <<-HTML
    <a href="#{target.canonical_path}">thư đơn</a> của bạn.
    HTML
  end

  def on_unlike_event(target, memoir : Memoir)
    action = Unotif::Action.map_liking(target)
    Unotif.remove_notif(action, target.id.as(Int32), memoir.viuser_id)
  end
end
