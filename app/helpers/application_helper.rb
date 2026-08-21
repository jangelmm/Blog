module ApplicationHelper
  def markdown(text, post = nil)
    return "".html_safe if text.blank?

    # 1. Bloques de Obsidian
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
          if asset.file.image?
            # 1. Renderizado para imágenes (.png, .jpg, .webp, etc.)
            file_url = rails_blob_path(asset.file, only_path: true)
            html_block = %Q(<img src="#{file_url}" alt="#{display_name}" class="obsidian-embedded-image" style="max-width: 100%; height: auto; border-radius: 8px; margin: 1.5rem auto; display: block; border: 1px solid var(--border-light);">)

          elsif asset.file.content_type == "application/pdf"
            # 2. Renderizado para PDFs (Visor integrado estilo Notion)
            # Nota el disposition: :inline para que el navegador lo muestre en vez de descargarlo
            file_url = rails_blob_path(asset.file, disposition: :inline, only_path: true)
            html_block = %Q(<embed src="#{file_url}" type="application/pdf" width="100%" height="600px" style="border-radius: 8px; border: 1px solid var(--border-light); margin: 1.5rem 0;">)

          else
            # 3. Renderizado para documentos genéricos (.zip, .docx, etc. - la tarjeta gris)
            file_url = rails_blob_path(asset.file, disposition: :attachment, only_path: true)
            html_block = %Q(<a href="#{file_url}" download="#{display_name}" target="_blank" class="obsidian-file-card"><div class="file-icon"><i class="fa-solid fa-file-lines"></i></div><div class="file-info"><span class="filename">#{display_name}</span><span class="file-action">Haz clic para descargar</span></div><div class="download-icon"><i class="fa-solid fa-download"></i></div></a>)
          end

          obsidian_blocks << html_block
          "OBSIDIANPLACEHOLDER#{obsidian_blocks.size - 1}XYZ"
        else
          match
        end
      end
    end

    # 2. Bloques de Mermaid (¡NUEVO!)
    mermaid_blocks = []
    # Busca bloques que inicien con ```mermaid y terminen con ```
    text = text.gsub(/^```mermaid[ \t]*\r?\n(.*?)^```/m) do |match|
      mermaid_blocks << $1
      "MERMAIDPLACEHOLDER#{mermaid_blocks.size - 1}XYZ"
    end

    # 3. Bloques Matemáticos
    math_blocks = []
    text = text.gsub(/(\$\$.*?\$\$|\$.*?\$)/m) do |match|
      math_blocks << match
      "MATHBLOCKPLACEHOLDER#{math_blocks.size - 1}XYZ"
    end

    # 4. Renderizado Redcarpet
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

    # 5. Restaurar todo
    obsidian_blocks.each_with_index do |block, index|
      placeholder = "OBSIDIANPLACEHOLDER#{index}XYZ"
      html.gsub!("<p>#{placeholder}</p>", block)
      html.gsub!(placeholder, block)
    end

    mermaid_blocks.each_with_index do |block, index|
      placeholder = "MERMAIDPLACEHOLDER#{index}XYZ"
      mermaid_html = %Q(<pre class="mermaid" style="display: flex; justify-content: center; margin: 2rem 0; background: transparent; border: none;">\n#{block}\n</pre>)
      html.gsub!("<p>#{placeholder}</p>", mermaid_html)
      html.gsub!(placeholder, mermaid_html)
    end

    math_blocks.each_with_index do |block, index|
      html.gsub!("MATHBLOCKPLACEHOLDER#{index}XYZ", block)
    end

    html.html_safe
  end
end
