class PostsController < ApplicationController
  include PostsHelper
  before_action :require_login, except: [ :index, :show, :tree ]
  before_action :set_post, only: [ :edit, :update, :destroy ]

  def index
    @posts = logged_in? ? Post.order(path: :asc, title: :asc) : Post.published.order(path: :asc, title: :asc)
  end

  def show
    @post = Post.find_by!(path: params[:path], slug: params[:slug])
  rescue ActiveRecord::RecordNotFound
    ruta_intentada = "#{params[:path]}/#{params[:slug]}".chomp("/")

    @posts = Post.where("path = ? OR path LIKE ?", ruta_intentada, "#{ruta_intentada}/%")

    if @posts.exists?
      @tree = build_tree(@posts, ruta_intentada)
      params[:path] = ruta_intentada

      render :tree
    else
      render template: "errors/not_found", status: :not_found
    end
  end

  def tree
    prefix = params[:path].to_s.chomp("/")
    @posts = Post.where("path = ? OR path LIKE ?", prefix, "#{prefix}/%").order(:path, :title)
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
    params.require(:post).permit(:title, :description, :body, :path, :published, :image)
  end
end
