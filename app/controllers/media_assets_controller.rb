class MediaAssetsController < ApplicationController
  before_action :require_login

  def index
    @current_path = params[:path] || "General"
    @assets = MediaAsset.where(path: @current_path).order(created_at: :desc)
  end

  def create
    if params[:files].present?
      params[:files].each do |file|
        asset = MediaAsset.new(path: params[:path])
        asset.file.attach(file)
        asset.save
      end
      redirect_to media_assets_path(path: params[:path]), notice: "Archivos subidos correctamente."
    else
      redirect_to media_assets_path(path: params[:path]), alert: "No se seleccionó ningún archivo."
    end
  end

  def destroy
    @asset = MediaAsset.find(params[:id])
    path = @asset.path
    @asset.destroy
    redirect_to media_assets_path(path: path), notice: "Archivo eliminado."
  end
end
