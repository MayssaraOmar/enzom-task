class ApplicationController < ActionController::Base
    # so it can work with postman
    protect_from_forgery unless: -> { request.format.json? }
end
