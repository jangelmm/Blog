module ApplicationHelper
  def markdown(text, post = nil)
    return "".html_safe if text.blank?

    if text.include?("![[")
      text = text.gsub(/!\[\[(.*?)\]\]/) do |match|
        image_identifier = $1
        asset = nil

        if image_identifier.start_with?("/")
          parts = image_identifier.split("/")
          filename = parts.pop
          folder_path = parts.reject(&:blank?).join("/")

          asset = MediaAsset.joins(file_attachment: :blob)
                            .find_by(path: folder_path, active_storage_blobs: { filename: filename })

        elsif post.present?
          asset = MediaAsset.joins(file_attachment: :blob)
                            .find_by(path: post.path, active_storage_blobs: { filename: image_identifier })
        end

        if asset&.file&.attached?
          "![#{filename || image_identifier}](#{url_for(asset.file)})"
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
