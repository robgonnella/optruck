class Users::RegistrationsController < Devise::RegistrationsController
  prepend_before_action :require_no_authentication, :only => []
  prepend_before_action :authenticate_scope!
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]
  before_action :authorize

  # GET /resource/sign_up
  # def new
  #   super
  # end

  def index
    @users = User.all
  end

  # POST /resource
  def create
    build_resource(sign_up_params)
    resource.save
    yield resource if block_given?
    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        # sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  # GET /resource/edit
  def edit
    @user = User.find(params[:id])
  end

  # PUT /resource
  def update
    begin
      @user = User.find(params[:id])
      params[:user].each_pair do |k, v|
        if @user[k] != v then @user[k] = v end
      end
      @user.save
      flash_key = :updated
      redirect_to users_path
    rescue => e
      flash_key = :update_failed
      redirect_to edit_user_registration_path(:id => params[:id])
    end
    set_flash_message :notice, flash_key
  end

  def update_password
    set_minimum_password_length
    @user = User.find(params[:id])
    user = params[:user]

    if user[:new_password] === ""
      flash_key = :missing_new_password
      redirect_to edit_user_registration_path(:id => params[:id])
      return set_flash_message :notice, flash_key
    end

    if user[:password_confirmation] === ""
      flash_key = :missing_password_confirmation
      redirect_to edit_user_registration_path(:id => params[:id])
      return set_flash_message :notice, flash_key
    end

    if user[:new_password] != user[:password_confirmation]
      flash_key = :no_match
      redirect_to edit_user_registration_path(:id => params[:id])
      return set_flash_message :notice, flash_key
    end

    if user[:new_password].length < @minimum_password_length
      flash_key = :password_min_error
      redirect_to edit_user_registration_path(:id => params[:id])
      return set_flash_message :notice, flash_key
    end

    @user.password = user[:new_password]

    begin
      @user.save
      flash_key = :updated
      redirect_to users_path
    rescue => e
      flash_key = :update_failed
      redirect_to edit_user_registration_path(:id => params[:id])
    end
    set_flash_message :notice, flash_key
  end

  # DELETE /resource
  def destroy
    begin
      user = User.find(params[:id])
      user.destroy
      flash_key = :destroyed
    rescue => e
      flash_key = :failed_to_destroy
    end
    redirect_to users_path
    set_flash_message :notice, flash_key
  end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  private
  def authorize
    return redirect_to root_path if current_user.nil?
    user = User.find(current_user.id)
    return redirect_to root_path if user != current_user
    redirect_to root_path if current_user.account_type != 'admin'
  end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(:first_name, :last_name, :email, :password, :account_type) }
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update) { |u| u.permit(:first_name, :last_name, :email, :account_type) }
  end

  # The path used after sign up.
  def after_sign_up_path_for(users)
    # super(users)
    users_path
  end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
