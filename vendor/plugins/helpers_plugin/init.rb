require 'helpers_plugin'
require 'added_function'
require 'error_helper'

ActionController::Base.send :helper, HelpersPlugin
ActionController::Base.send :include, AddedFunction
ActionController::Base.send :helper, AddedFunction