Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  # ── Home ──────────────────────────────────────────────
  root "home#index"

  # ── Blog (admin: new/edit/update/destroy) ───────────────
  # El "show" público lo maneja la ruta jerárquica *path/:slug al final.
  resources :posts, path: "blog", param: :slug, except: [ :show ] do
    collection do
      get :paths, defaults: { format: :json }
    end
  end

  # ── Proyectos ────────────────────────────────────────────
  resources :projects, param: :slug

  # ── About (singleton, editable solo por el admin) ───────
  resource :about, only: [ :show, :edit, :update ], controller: "about"

  # ── Login OCULTO (no aparece en ningún menú/nav) ────────
  get    "control-panel-x7q9/login",  to: "sessions#new",     as: :login
  post   "control-panel-x7q9/login",  to: "sessions#create"
  delete "logout",                    to: "sessions#destroy", as: :logout

  # ── Rutas jerárquicas públicas del blog (van al final) ──
  # /blog/Programacion/Ruby/Rails/PrimerPrograma -> post individual
  # /blog/Programacion/Ruby/                     -> árbol de esa rama
  get "blog/*path/:slug", to: "posts#show", as: :post_show,
      constraints: { path: /[^\/]+(\/[^\/]+)*/ }
  get "blog/*path", to: "posts#tree", as: :post_tree,
      constraints: { path: /.+/ }

  match "/404", to: "errors#not_found", via: :all
  match "/500", to: "errors#internal_server_error", via: :all
end
