module SchedulesHelper

  def check_products
    if @products_ids.blank?
      flash.now[:error] = "Please select any products."
      @checked_products = 'error'
      return false
    end
    true
  end

  def check_time_params
    if params[:from_time].blank? || params[:from_date].blank? || params[:to_time].blank? || params[:to_date].blank?
      flash.now[:error] = "Please choose 'Scheduled from' and 'Scheduled to'. These fields are required."
      @checked_dates = 'error'
      return false
    end
    true
  end

  def check_correct_time
    @from = Time.zone.parse("#{params[:from_date]} #{params[:from_time]}")
    @to = Time.zone.parse("#{params[:to_date]} #{params[:to_time]}")
    if @from >= @to
      flash.now[:error] = 'Set Scheduled is incorrect. Please check it.'
      @checked_dates = 'error'
      return false
    end
    true
  end

end

