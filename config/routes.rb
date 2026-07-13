Rails.application.routes.draw do
  # ── Home ──────────────────────────────────────────────
  root "home#index"

  # ── Blog (Markdown, slug como parámetro) ────────────────
  resources :posts, path: "blog", param: :slug

  # ── Proyectos ────────────────────────────────────────────
  resources :projects, param: :slug

  # ── About (singleton, editable solo por el admin) ───────
  resource :about, only: [:show, :edit, :update], controller: "about"

  # ── Login OCULTO (no aparece en ningún menú/nav) ────────
  # Cambia "control-panel-x7q9" por lo que tú quieras que sea
  # tu ruta secreta antes de desplegar a producción.
  get    "control-panel-x7q9/login",  to: "sessions#new",     as: :login
  post   "control-panel-x7q9/login",  to: "sessions#create"
  delete "logout",                    to: "sessions#destroy", as: :logout
end
