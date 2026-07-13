# ── Usuario administrador (único usuario del sistema) ─────
admin_email    = ENV.fetch("ADMIN_EMAIL", "jesusangelmartinezmendoza0702@gmail.com")
admin_password = ENV.fetch("ADMIN_PASSWORD", "vMw?(@D}bY;Yh|K6")

user = User.find_or_initialize_by(email: admin_email)
user.password = admin_password
user.save!
puts "Admin listo -> email: #{admin_email} / password: #{admin_password}"
puts "¡IMPORTANTE! Cambia estas credenciales antes de producción."

# ── Perfil (About) ─────────────────────────────────────────
Profile.first_or_create!(
  name: "Jesus Angel Martinez Mendoza",
  role: "Software Engineer · PhD en Ciencias Computacionales",
  bio: "Diseño y construyo soluciones de software para entornos científicos y " \
       "plataformas SaaS de alto rendimiento. Mi trabajo une la ingeniería de " \
       "software robusta con las necesidades reales de laboratorios, observatorios " \
       "y equipos de investigación.",
  quote: "Convertir datos complejos en conocimiento accesible es lo que me mueve.",
  location_label: "Observatorio Astronómico Nacional · 2024"
)

# ── Ejemplos de entradas de blog ───────────────────────────
Post.find_or_create_by!(slug: "optimizando-pipelines-rust-arrow") do |p|
  p.title       = "Optimizando pipelines de datos astronómicos con Rust y Apache Arrow"
  p.description = "Cómo logramos reducir en un 40% el tiempo de procesamiento de imágenes del telescopio LSST usando Rust."
  p.tag         = "Computación Científica"
  p.published_at = Time.current
  p.body = <<~MD
    # Optimizando pipelines de datos astronómicos

    Cómo logramos reducir en un **40%** el tiempo de procesamiento de imágenes
    del telescopio LSST usando *Rust* como capa de alto rendimiento.

    ```rust
    fn main() {
        println!("hola, arrow!");
    }
    ```
  MD
end

# ── Ejemplo de proyecto ─────────────────────────────────────
Project.find_or_create_by!(slug: "astroreduce") do |pr|
  pr.title       = "AstroReduce"
  pr.description = "Pipeline de reducción de datos espectroscópicos para telescopios de clase 4m."
  pr.tech_stack  = "Python, C++, CUDA"
  pr.icon        = "fa-solid fa-satellite"
  pr.body        = "Procesa noches completas de observación en minutos gracias a la paralelización en GPU."
end
