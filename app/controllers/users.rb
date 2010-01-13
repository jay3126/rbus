class Users < Application
  
  before :ensure_is_same_user, :only => [:edit, :update, :delete, :destroy]
  
  def index
    render
  end

  def home
    if session.user
      @user = session.user
      render :show
    else
      @trip = Trip.new
      render :template => "trips/new"
    end
  end

  def show(id)
    @user = User.get(id)
    raise NotFound unless @user
    render
  end

  def edit(id)
    @user = User.get(id)
    raise NotFound unless @user
    render
  end

  def update(id, user)
    @user = User.get(id)
    raise NotFound unless @user
    if @user.update(user)
      redirect resource(@user), :message => {:success => "Account updated"}
    else
      display @user, :edit
    end
  end

  private
  def ensure_is_same_user
    debugger
    raise NotOwner unless session.user.id == params[:id].to_i
  end
  
end
