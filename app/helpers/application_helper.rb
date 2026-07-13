module ApplicationHelper
  # Convierte texto Markdown a HTML seguro usando Redcarpet
  # (GitHub-like: tablas, bloques de código, tachado, autolinks...)
  def markdown(text)
    return "".html_safe if text.blank?

    renderer = Redcarpet::Render::HTML.new(
      filter_html: false,
      hard_wrap: true
    )

    options = {
      fenced_code_blocks: true,
      tables: true,
      autolink: true,
      strikethrough: true,
      superscript: true,
      no_intra_emphasis: true,
      space_after_headers: true
    }

    Redcarpet::Markdown.new(renderer, options).render(text).html_safe
  end
end
