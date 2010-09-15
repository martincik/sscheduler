module SchedulesHelper

  def check_products
    if @products_ids.blank?
      flash.now[:error] = "Please select at least one product before you hit schedule or unschedule."
      @checked_products = 'error'
      return false
    end
    true
  end

  def check_time_params
    if params[:from_time].blank? || params[:from_date].blank? || params[:to_time].blank? || params[:to_date].blank?
      flash.now[:error] = "Please make sure you fill in all both dates and times before you hit schedule or unschedule."
      @checked_dates = 'error'
      return false
    end
    true
  end

  def check_correct_time
    @from = Time.zone.parse("#{params[:from_date]} #{params[:from_time]}")
    @to = Time.zone.parse("#{params[:to_date]} #{params[:to_time]}")
    if (@from.past? or @to.past?)
      flash.now[:error] = 'You choose date/time from past. Please select only date/times for future.'
      @checked_dates = 'error' and return false
    end
    if (@from >= @to)
      flash.now[:error] = 'Your "to" date/time is sooner than your "from" date/time. Make sure you have right order.'
      @checked_dates = 'error' and return false
    end
    true
  end

end

