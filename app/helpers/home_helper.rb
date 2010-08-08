module HomeHelper

  def check_schedule
    check = true
    flash.now[:error] = ""
    if @products_ids.blank?
      flash[:error] = "Please select any products."
      @checked_products = 'error'
      check = false
    end

    if params[:commit] == "schedule"
      if params[:from_time].blank? || params[:from_date].blank? || params[:to_time].blank? || params[:to_date].blank?
        flash[:error] += "<br />Please choose 'Scheduled from' and 'Scheduled to'. These fields are required."
        @checked_dates = 'error'
        return false
      end

      f_date, t_date = params[:from_date].split('/'), params[:to_date].split('/')
      f_time, t_time = params[:from_time].split(':'), params[:to_time].split(':')

      @from = Time.zone.parse("#{f_date[2]}-#{f_date[1]}-#{f_date[0]} #{f_time[0]}:#{f_time[1]}")
      @to = Time.zone.parse("#{t_date[2]}-#{t_date[1]}-#{t_date[0]} #{t_time[0]}:#{t_time[1]}")
      if @from >= @to
        flash[:error] += '<br />Set Scheduled is incorrect. Please check it.'
        @checked_dates = 'error'
        check = false
      end
    end

    return check
  end

end

