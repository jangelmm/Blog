# app/helpers/application_helper.rb
module ApplicationHelper
  # Modificamos el método para aceptar el 'post' como segundo parámetro
  def markdown(text, post = nil)
    return "".html_safe if text.blank?

    # --- INICIO MAGIA PARA OBSIDIAN ---
    # Si pasamos el post y tiene imágenes, buscamos y reemplazamos la sintaxis ![[...]]
    if post.present? && post.body_images.attached?
      text = text.gsub(/!\[\[(.*?)\]\]/) do |match|
        filename = $1 # Captura el nombre del archivo, ej: "imagen-test.png"

        # Buscamos si existe una imagen adjunta con ese nombre exacto
        attached_image = post.body_images.find { |img| img.filename.to_s == filename }

        if attached_image
          # Si existe, lo convertimos a Markdown estándar inyectando la ruta de Rails
          "![#{filename}](#{url_for(attached_image)})"
        else
          # Si la imagen no está adjunta en el post, lo dejamos como estaba
          match
        end
      end
    end
    # --- FIN MAGIA PARA OBSIDIAN ---

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
