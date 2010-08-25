class SchedulesController < ApplicationController

  include SchedulesHelper

  around_filter :shopify_session

  def create
    @products_ids = params[:products].try(:keys) || []
    params[:commit] == "schedule" ? schedule : unschedule
  end

  private

    def schedule
      @from_time, @to_time, @from_date, @to_date = params[:from_time], params[:to_time], params[:from_date], params[:to_date]
      respond_to do |format|
        if check_products and check_time_params and check_correct_time
          ScheduledProduct::schedule(current_store, @products_ids, @from, @to)
          flash[:notice] = "Scheduling was successfully"
          format.html { redirect_to scheduled_products_path }
          format.xml { render :xml => @products, :notice => flash[:notice]}
        else
          get_shopify_products
          format.xml { render :xml => flash }
          # Couldnt use render scheduled_products_path, because it is /scheduled_products and it isnt template.
          format.html { render :template => 'scheduled_products/index' }
        end
      end

    end

    def unschedule
      respond_to do |format|
        if check_products
          ScheduledProduct::unschedule(current_store, @products_ids)
          flash[:notice] = 'Unscheduling was successfully.'
          format.xml { render :xml => @products, :notice => flash[:notice]}
        else
          format.xml { render :xml => flash }
        end
        format.html { redirect_to scheduled_products_path }
      end
    end

end

