class HomeController < ApplicationController
	allow_unauthenticated_access
	layout "landing"
	def index
	end
end
