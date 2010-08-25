require 'spec_helper'

describe ScheduledProductsController do

  # in spec_helper
  set_test_parameters.call

  it "should check redirect for index" do
    get 'index'
    response.should render_template('index')
    session[:shopify] = nil
    get 'index'
    response.should_not render_template('index')
  end

  it "should get shopify products and patch them with times" do
    get 'index'
    assigns[:products].should have(3).items
    assigns[:products].map(&:from_time).should_not include(nil)
  end

end

