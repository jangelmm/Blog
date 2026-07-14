module ApplicationHelper
  def markdown(text, post = nil)
    return "".html_safe if text.blank?

    if post.present? && post.body_images.attached?
      text = text.gsub(/!\[\[(.*?)\]\]/) do |match|
        filename = $1
        attached_image = post.body_images.find { |img| img.filename.to_s == filename }

        if attached_image
          "![#{filename}](#{url_for(attached_image)})"
        else
          match
        end
      end
    end

    math_blocks = []
    text = text.gsub(/(\$\$.*?\$\$|\$.*?\$)/m) do |match|
      math_blocks << match
      "MATHBLOCKPLACEHOLDER#{math_blocks.size - 1}XYZ"
    end

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

    html = Redcarpet::Markdown.new(renderer, options).render(text)

    math_blocks.each_with_index do |block, index|
      html.gsub!("MATHBLOCKPLACEHOLDER#{index}XYZ", block)
    end

    html.html_safe
  end
end
