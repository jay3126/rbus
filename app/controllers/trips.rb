require 'md5'
class Trips < Application
  provides :xml, :yaml, :js
  before :ensure_authenticated, :only => [:my]
  before :ensure_is_owner, :only => [:edit, :update, :delete, :destroy]

  def index
    if params[:user_id]
      @user = User.get(params[:user_id])
      @trips = @user.trips
    else
      @start_stop = Stop.first(:name => params[:from]) unless params[:from].blank?
      @end_stop = Stop.first(:name => params[:to]) unless params[:to].blank?
      @start_trips = @start_stop.nil? ? Trip.all : @start_stop.nearby_stops.starts 
      @end_trips = @end_stop.nil? ? Trip.all : @end_stop.nearby_stops.ends
      @trips = @start_trips & @end_trips
    end
    display @trips
  end


  def show(id)
    @trip = Trip.get(id)
    raise NotFound unless @trip
    @nearby_trips = @trip.nearby_trips
    display @trip
  end

  def new
    only_provides :html
    @trip = Trip.new
    display @trip
  end

  def edit(id)
    only_provides :html
    @trip = Trip.get(id)
    raise NotFound unless @trip
    display @trip
  end

  def create(trip)
    message = ""
    unless session.authenticated?
      @user = User.new(params[:user])
      @user.password = MD5.hexdigest(@user[:login])[0..9]
      @user.password_confirmation = @user.password
      if @user.save
        message = "Your account has been created. An email has been sent to #{@user.login} with your password."
        session.user = @user
        Merb.run_later do
          send_mail(ContactMailer, :signup, {
                    :from => "svs@rbus.in",
                    :to => @user.login,
                    :subject => "[rbus] Welcome to rbus",
                  }, {:user => @user, :password => @user.password})
        end
      else
        @trip = Trip.new(trip)
        @user.errors.keys.each{|k| @trip.errors["user #{k}"] = @user.errors[k]}
      end
    end
    if session.user
      debugger
      p_out_time = Chronic.parse(trip[:out_time])
      trip[:out_time] = p_out_time ? p_out_time.to_s.match(/\d\d:\d\d:\d\d/)[0].gsub(":","")[0..3] : nil
      p_in_time = Chronic.parse(trip[:in_time])
      trip[:in_time] = p_in_time ? p_in_time.to_s.match(/\d\d:\d\d:\d\d/)[0].gsub(":","")[0..3] : nil
      @trip = Trip.new(trip)
      @trip.user = session.user
      if @trip.save
        send_mail(ContactMailer, :new_trip, {
                    :from => "svs@rbus.in",
                    :to => @user.login,
                    :subject => "[rbus] Your trip has been created",
                  }, {:user => session.user, :trip => @trip})
        unless TWITTER_NAME.blank? or @trip.user.login == "svs@intellecap.net"
          Merb.run_later do
            httpauth = Twitter::HTTPAuth.new(TWITTER_NAME, TWITTER_PASSWORD) 
            link = "http://#{request.env["HTTP_HOST"]}#{resource(@trip)}"
            client = Twitter::Base.new(httpauth)
            client.update("#rbus #{@trip.user.nick} added a trip form #{@trip.start_stop.name[0..20]} to #{@trip.end_stop.name[0..20]}. #{link}")
          end
        end
        message += "Your trip from #{@trip.start_stop.name} to #{@trip.end_stop.name} has been registered."
        redirect resource(@trip), :message => {:success => message}
      else
        message[:error] = "Trip failed to be created"
        render :new
      end
    else
      render :new
    end
  end

  def update(id, trip)
    @trip = Trip.get(id)
    raise NotFound unless @trip
    if @trip.update(trip)
       redirect resource(@trip)
    else
      display @trip, :edit
    end
  end

  def delete
    render
  end

  def destroy(id)
    @trip = Trip.get(id)
    raise NotFound unless @trip
    if @trip.destroy
      redirect resource(session.user, :trips)
    else
      raise InternalServerError
    end
  end

  private

  def ensure_is_owner
    return unless params[:id]
    return true if session.user.login == "svs"
    @trip = Trip.get(params[:id])
    raise NotOwner unless @trip
    raise NotOwner unless session.user and (@trip.user == session.user)
  end
end # Trips
