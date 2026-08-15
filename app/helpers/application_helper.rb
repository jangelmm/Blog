module ApplicationHelper
  def markdown(text, post = nil)
    return "".html_safe if text.blank?

    obsidian_blocks = []

    if text.include?("![[")
      text = text.gsub(/!\[\[(.*?)\]\]/) do |match|
        image_identifier = $1.strip
        asset = nil
        display_name = image_identifier.split("/").last

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
          # TRUCO MAESTRO: Forzamos disposition: :inline para que Rails permita dibujar los SVG
          # en lugar de forzar su descarga por defecto (medida anti-XSS).
          file_url = rails_blob_path(asset.file, disposition: :inline, only_path: true)
          extension = File.extname(display_name).downcase

          html_block = case extension
          when ".png", ".jpg", ".jpeg", ".gif", ".webp"
            # Renderizado como imagen
            %Q(<img src="#{file_url}" alt="#{display_name}" class="obsidian-image" loading="lazy" />)

          when ".pdf"
            # Renderizado como Iframe (Visor PDF limpio sin encabezado)
            %Q(<iframe src="#{file_url}" class="obsidian-pdf" title="#{display_name}" style="width: 100%; height: 750px; border: 1px solid rgba(255, 255, 255, 0.1); border-radius: 8px; margin: 1.5rem 0; background-color: var(--bg-secondary);"></iframe>)

          else
            # Tarjeta de descarga (.excalidraw, .xlsx, .txt, .zip, etc.)
            %Q(<a href="#{file_url}" download="#{display_name}" target="_blank" class="obsidian-file-card"><div class="file-icon"><i class="fa-solid fa-file-lines"></i></div><div class="file-info"><span class="filename">#{display_name}</span><span class="file-action">Haz clic para descargar</span></div><div class="download-icon"><i class="fa-solid fa-download"></i></div></a>)
          end

          obsidian_blocks << html_block
          "OBSIDIANPLACEHOLDER#{obsidian_blocks.size - 1}XYZ"
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

    # Restaurar componentes de Obsidian y Matemáticas de forma segura
    obsidian_blocks.each_with_index do |block, index|
      placeholder = "OBSIDIANPLACEHOLDER#{index}XYZ"
      html.gsub!("<p>#{placeholder}</p>", block)
      html.gsub!(placeholder, block)
    end

    math_blocks.each_with_index do |block, index|
      html.gsub!("MATHBLOCKPLACEHOLDER#{index}XYZ", block)
    end

    html.html_safe
  end
end
