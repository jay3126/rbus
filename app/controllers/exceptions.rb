class Exceptions < Merb::Controller
  
  # handle NotFound exceptions (404)
  def not_found
    render :format => :html
  end

  # handle NotAcceptable exceptions (406)
  def not_acceptable
    render :format => :html
  end

  def not_owner
    if request.env['HTTP_REFERER'] 
      redirect request.env['HTTP_REFERER'], :message => { :error => 'Sorry, you cannot do that' }
    else
      render
    end
  end

end

class NotOwner <  Merb::ControllerExceptions::Unauthorized; end
