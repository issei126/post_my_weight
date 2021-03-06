class UsersController < BaseController
  before_action :login_required, only: [:edit ]

  def edit
    @user = @current_user
  end

  def update
    @user = User.find(params[:id]) 
    @user.name = params[:user][:name]
    @user.update_name = params[:user][:update_name] == "1" ? true : false
    if @user.save then
      flash[:notice] = "設定を保存しました"
    else
      flash[:notice] = "設定の保存にしっぱい"
    end
    redirect_to root_path
      
  end
end
