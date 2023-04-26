require "../dboard/*"
require "../member/*"
require "../review/*"
require "../wnovel/*"

module CV::Notifier
  extend self

  def render_content(uname : String, &)
    String.build do |html|
      html << "<p>"
      html << %(<a href="/@#{uname}" class="cv-user">#{uname}</a>)
      yield html
      html << "</p>"
    end
  end
end
