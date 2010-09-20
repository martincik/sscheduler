class SchedulesController < ApplicationController

  include SchedulesHelper

  around_filter :shopify_session

  def create
    @products_ids = params[:products].try(:keys) || []
    params[:schedule].nil? ? unschedule : schedule
  end

  private

    def schedule
      @from_time, @to_time = params[:from_time], params[:to_time]
      @from_date, @to_date = params[:from_date], params[:to_date]

      unless check_products and check_time_params and check_correct_time
        render_products_on_page and return
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
      # cannot put redirect, because of flash.now keeping from check_products
      render_products_on_page
    end

    def render_products_on_page
      get_shopify_products(params[:page])
      render :template => 'scheduled_products/index'
    end

end

