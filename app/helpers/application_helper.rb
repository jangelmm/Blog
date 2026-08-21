module ApplicationHelper
  # =======================================================================
  # 1. RENDERIZADOR PERSONALIZADO PARA OBSIDIAN CALLOUTS
  # =======================================================================
  class ObsidianRenderer < Redcarpet::Render::HTML
    def block_quote(quote)
      parsed = quote.strip

      # Buscamos si el bloque empieza con la sintaxis de callout: [!tipo]
      if parsed.match(/\A<p>\s*\[!([a-zA-Z]+)\]([+-]?)(.*?)(?:<\/p>|<br>|\n)/)
        type = $1.downcase
        title = $3.strip
        title = type.capitalize if title.blank?

        # Limpiamos la primera línea para dejar solo el cuerpo del contenido
        content = parsed.sub(/\A<p>\s*\[![a-zA-Z]+\][+-]?[^\n<]*(?:<\/p>|<br>|\n)?/, "<p>")
        content = "" if content == "<p>" || content == "<p></p>"

        config = case type
        when "info", "todo"         then { color: "8, 109, 221",   icon: "fa-solid fa-circle-info" }
        when "note"                 then { color: "138, 138, 138", icon: "fa-solid fa-pencil" }
        when "tip", "hint"          then { color: "0, 191, 142",   icon: "fa-solid fa-lightbulb" }
        when "success"              then { color: "8, 185, 78",    icon: "fa-solid fa-check" }
        when "question", "faq"      then { color: "236, 117, 0",   icon: "fa-solid fa-circle-question" }
        when "warning", "caution"   then { color: "236, 117, 0",   icon: "fa-solid fa-triangle-exclamation" }
        when "failure", "danger", "bug" then { color: "227, 82, 8", icon: "fa-solid fa-bolt" }
        when "example"              then { color: "120, 82, 238",  icon: "fa-solid fa-list-ul" }
        when "quote", "cite"        then { color: "158, 158, 158", icon: "fa-solid fa-quote-left" }
        else { color: "138, 138, 138", icon: "fa-solid fa-pencil" }
        end

        <<~HTML
          <div class="obsidian-callout" data-callout="#{type}" style="--callout-color: #{config[:color]};">
            <div class="callout-title">
              <div class="callout-icon"><i class="#{config[:icon]}"></i></div>
              <div class="callout-title-text">#{title}</div>
            </div>
            <div class="callout-content">
              #{content}
            </div>
          </div>
        HTML
      else
        "<blockquote>\n#{quote}</blockquote>\n"
      end
    end
  end

  # =======================================================================
  # 2. MOTOR PRINCIPAL DE MARKDOWN (PIPELINE DE EXTRACCIÓN)
  # =======================================================================
  def markdown(text, post = nil)
    return "".html_safe if text.blank?

    # PASO 0: Forzar la separación de blockquotes consecutivos
    # Reemplaza líneas en blanco entre dos '>' con un comentario HTML invisible
    text = text.gsub(/^([ \t]*>.*)\n([ \t]*\n)+(?=[ \t]*>)/, "\\1\n\n<!-- split -->\n\n")

    # PASO 1: Proteger Bloques de Mermaid (se evalúan y ocultan primero)
    mermaid_blocks = []
    text = text.gsub(/^```mermaid[ \t]*\r?\n([\s\S]*?)^```/m) do |match|
      mermaid_blocks << $1
      "MERMAIDPLACEHOLDER#{mermaid_blocks.size - 1}XYZ"
    end

    # PASO 2: Proteger TODO el código (Fenced y en línea) para evitar falsos positivos con $ y ![[
    code_blocks = []
    text = text.gsub(/```[\s\S]*?```/) do |match|
      code_blocks << match
      "CODEBLOCKPLACEHOLDER#{code_blocks.size - 1}XYZ"
    end

    inline_code_blocks = []
    text = text.gsub(/`[^`\n]+`/) do |match|
      inline_code_blocks << match
      "INLINECODEPLACEHOLDER#{inline_code_blocks.size - 1}XYZ"
    end

    # PASO 3: Evaluar Bloques de Obsidian
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
          asset = MediaAsset.joins(file_attachment: :blob).find_by(path: folder_path, active_storage_blobs: { filename: filename })
        elsif post.present?
          asset = MediaAsset.joins(file_attachment: :blob).find_by(path: post.path, active_storage_blobs: { filename: image_identifier })
        end

        if asset&.file&.attached?
          if asset.file.image?
            file_url = rails_blob_path(asset.file, only_path: true)
            html_block = %Q(<img src="#{file_url}" alt="#{display_name}" class="obsidian-embedded-image" style="max-width: 100%; height: auto; border-radius: 8px; margin: 1.5rem auto; display: block; border: 1px solid var(--border-light);">)
          elsif asset.file.content_type == "application/pdf"
            file_url = rails_blob_path(asset.file, disposition: :inline, only_path: true)
            html_block = %Q(<embed src="#{file_url}" type="application/pdf" width="100%" height="600px" style="border-radius: 8px; border: 1px solid var(--border-light); margin: 1.5rem 0;">)
          else
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

    # PASO 4: Evaluar Matemáticas (Ahora es 100% seguro porque los scripts Bash están protegidos)
    math_blocks = []
    # Math multilínea
    text = text.gsub(/\$\$([\s\S]*?)\$\$/) do |match|
      math_blocks << match
      "MATHBLOCKPLACEHOLDER#{math_blocks.size - 1}XYZ"
    end
    # Math en línea (modificado para evitar capturar variables huérfanas de Bash si no usan comillas)
    text = text.gsub(/\$(?!\s)([^\$\n]+?)(?<!\s)\$/) do |match|
      math_blocks << match
      "MATHBLOCKPLACEHOLDER#{math_blocks.size - 1}XYZ"
    end

    # PASO 5: DEVOLVER EL CÓDIGO AL TEXTO ANTES DE REDCARPET
    inline_code_blocks.each_with_index do |block, index|
      text.gsub!("INLINECODEPLACEHOLDER#{index}XYZ", block)
    end
    code_blocks.each_with_index do |block, index|
      text.gsub!("CODEBLOCKPLACEHOLDER#{index}XYZ", block)
    end

    # PASO 6: Renderizado Redcarpet
    renderer = ObsidianRenderer.new(filter_html: false, hard_wrap: true)
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

    # PASO 7: Restaurar HTML Complejo (Obsidian, Mermaid, Math)
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
