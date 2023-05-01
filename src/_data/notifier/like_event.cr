require "./_notif_base"

module CV::Notifier
  def on_like_event(target, memoir : Memoir, byuser : String)
    return if target.viuser_id == memoir.viuser_id

    action = Unotif::Action.map_liking(target)
    return if Unotif.find(action, target.id, memoir.viuser_id)

    content = render_content(byuser) do |html|
      html << " đã thích " << liking_content(target)
    end

    output = Unotif.new(
      viuser_id: target.viuser_id, content: liking_content(target),
      action: action, object_id: target.id, byuser_id: memoir.viuser_id,
      created_at: Time.unix(memoir.liked_at)
    )

    Log.info { output.to_json.colorize.yellow }
    output.create!
  end

  private def liking_content(target : Rpnode) : String
    gdroot = Gdroot.find!(id: target.gdroot_id)
    <<-HTML
    <a href="#{gdroot.gdrepl_link(target.id)}">bài viết của bạn</a>
    trong #{gdroot.thread_type} <a href="#{gdroot.origin_link}">#{gdroot.oname}</a>.</p>
    HTML
  end

  private def liking_content(target : Dtopic)
    <<-HTML
    chủ đề <a href="#{target.canonical_path}">#{target.title}</a> của bạn.
    HTML
  end

  private def liking_content(target : Vicrit)
    <<-HTML
    <a href="#{target.canonical_path}">đánh giá truyện</a> của bạn.
    HTML
  end

  private def liking_content(target : Vilist)
    <<-HTML
    <a href="#{target.canonical_path}">thư đơn</a> của bạn.
    HTML
  end

  def on_unlike_event(target, memoir : Memoir)
    action = Unotif::Action.map_liking(target)
    Unotif.remove_notif(action, target.id, memoir.viuser_id)
  end
end
