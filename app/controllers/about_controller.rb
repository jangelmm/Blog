class AboutController < ApplicationController
  before_action :require_login, only: [ :edit, :update ]

  def show
    @profile = Profile.first_or_create!(name: "Tu nombre")
  end

  def edit
    @profile = Profile.first_or_create!(name: "Tu nombre")
  end

  def update
    @profile = Profile.first_or_create!(name: "Tu nombre")

    if @profile.update(profile_params)
      redirect_to about_path, notice: "Perfil actualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:profile).permit(:name, :role, :bio, :quote, :location_label, :photo)
  end
end
