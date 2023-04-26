require "./_notif_base"

module CV::Notifier
  def on_like_event(target, memoir : Memoir, byuser : String)
    return if target.viuser_id == memoir.viuser_id

    action = Unotif::Action.map_liking(target)
    return if Unotif.find(action, target.id, memoir.viuser_id)

    content = render_content(byuser) do |html|
      html << " đã thích " << liking_content(target)
    end

    Unotif.new(
      viuser_id: target.viuser_id, content: liking_content(target, byuser),
      action: action, object_id: target.id, byuser_id: memoir.viuser_id,
      created_at: Time.unix(memoir.liked_at)
    ).create!
  end

  private def liking_content(target : Rpnode) : String
    rproot = Rproot.find!(id: target.rproot_id)

    repl_link = "/gd/r#{rproot.id}#r#{target.id}"
    root_link = rproot._link

    <<-HTML
    <a href="#{repl_link}">bài viết của bạn</a> trong #{rproot._type}
    <a href="#{root_link}">#{rproot._name}</a>.</p>
    HTML
  end

  private def liking_content(target : Dtopic)
    link = "/gd/t-#{target.id}-#{target.tslug}"
    <<-HTML
    chủ đề <a href="#{link}">#{target.title}</a> do bạn tạo.
    HTML
  end

  private def liking_content(target : Vicrit)
    <<-HTML
    <a href="/uc/v#{target.id}">đánh giá truyện</a> của bạn.
    HTML
  end

  private def liking_content(target : Vilist)
    <<-HTML
    <a href="/ul/v#{target.id}-#{target.tslug}">thư đơn</a> của bạn.
    HTML
  end

  def on_unlike_event(target, memoir : Memoir)
    action = Unotif::Action.map_liking(target)
    Unotif.remove_notif(action, target.id, memoir.viuser_id)
  end
end
