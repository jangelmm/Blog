class PostsController < ApplicationController
  include PostsHelper
  before_action :require_login, except: [ :index, :show, :tree ]
  before_action :set_post, only: [ :edit, :update, :destroy ]

  def index
    @posts = logged_in? ? Post.recent : Post.published.recent
  end

  def show
    @post = Post.find_by!(path: params[:path], slug: params[:slug])
  rescue ActiveRecord::RecordNotFound
    redirect_to post_tree_path(path: params[:path]), alert: "Esa entrada ya no existe. Aquí tienes el árbol de esta sección."
  end

  def tree
    prefix = params[:path].to_s.chomp("/")
    @posts = Post.where("path = ? OR path LIKE ?", prefix, "#{prefix}/%")
    @tree = build_tree(@posts, prefix)
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)

    if @post.save
      redirect_to post_show_path(path: @post.path, slug: @post.slug), notice: "Entrada publicada."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    # 1. Procesar la eliminación de imágenes seleccionadas en el checkbox
    if params[:purge_images].present?
      params[:purge_images].each do |image_id|
        image = @post.body_images.find_by(id: image_id)
        image.purge if image # Esto elimina el archivo de la base de datos y del disco
      end
    end

    # 2. Actualizar el resto del post
    if @post.update(post_params)
      redirect_to post_show_path(path: @post.path, slug: @post.slug), notice: "Entrada actualizada."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
    redirect_to posts_path, notice: "Entrada eliminada."
  end

  def paths
    render json: Post.distinct.pluck(:path).compact.sort
  end

  private

  def set_post
    @post = Post.find_by!(slug: params[:slug])
  end

  def post_params
    params.require(:post).permit(:title, :description, :body, :path, :published, :image, body_images: [])
  end
end
