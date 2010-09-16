class SchedulesController < ApplicationController

  include SchedulesHelper

  around_filter :shopify_session

  def create
    @products_ids = params[:products].try(:keys) || []
    params[:commit] && params[:commit].downcase == 'unschedule' ? unschedule : schedule
  end

  private

    def schedule
      @from_time, @to_time = params[:from_time], params[:to_time]
      @from_date, @to_date = params[:from_date], params[:to_date]

      unless check_products and check_time_params and check_correct_time
        get_shopify_products(params[:page])
        render :template => 'scheduled_products/index' and return
      end

      ScheduledProduct::schedule(current_store, @products_ids, @from, @to)
      flash[:notice] = "Successfuly added schedule information to our database."

      redirect_to scheduled_products_path
    end

    def unschedule
      if check_products
        ScheduledProduct::unschedule(current_store, @products_ids)
        flash[:notice] = 'Successfuly removed schedule information from our database.'
      end

      redirect_to scheduled_products_path
    end

end

