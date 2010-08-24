module HomeHelper

  def check_products
    if @products_ids.blank?
      flash[:error] = "Please select any products."
      @checked_products = 'error'
      return false
    end
    return true
  end

  def check_times
    check = true
    flash[:error] = '' if flash[:error].nil?

    if params[:commit] == "schedule"
      if params[:from_time].blank? || params[:from_date].blank? || params[:to_time].blank? || params[:to_date].blank?
        flash.now[:error] += "<br />Please choose 'Scheduled from' and 'Scheduled to'. These fields are required."
        @checked_dates = 'error'
        return false
      end

      @from = Time.zone.parse("#{params[:from_date]} #{params[:from_time]}")
      @to = Time.zone.parse("#{params[:to_date]} #{params[:to_time]}")

      if @from >= @to
        flash.now[:error] += '<br />Set Scheduled is incorrect. Please check it.'
        @checked_dates = 'error'
        check = false
      end
    end

    return check
  end

end

