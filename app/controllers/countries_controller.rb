require 'dotenv'
require 'json'
Dotenv.load

include ResponseHelper

class CountriesController < ApplicationController
  before_action :set_paging_parameters ,only: [:index]

  def index
    @countries = Country.all.paginate(page: @page_number, per_page: @page_size)
    render_countries(data: @countries)
  end

  def show

  end

  def sync
    
  end

  def init
    @response =  RestClient.get "https://countriesnow.space/api/v0.1/countries/population/cities", {content_type: :json, accept: :json, "user-key": ENV["API_KEY"]}
    @data = JSON.parse(@response.body)["data"]
    @countries = @data.map do |country|
      puts (country)
      @existing_country = Country.find_by(:name=>country["country"], :city_name => country["city"])
      if !@existing_country
        @new_country = Country.new(:name => country["country"], :city_name => country["city"])
        if !@new_country.save
          # message = new_country.error_message
          message = ""
          @new_country.errors.full_messages.each do |msg| 
               message += " , " + msg
          end
          return render_error(error: "saving country", message: message, status: :unprocessable_entity)
        end
        @existing_country = Country.find_by(:name=>country["country"], :city_name => country["city"])
      end
      
      @populations = country["populationCounts"].map do |population|
        puts (population)

        @new_population = Population.new(:year => population["year"].to_i, :count => population["value"].to_i, :sex => population["sex"], :reliabilty => population["reliabilty"])
        @new_population.country = @existing_country
        if !@new_population.save
          message = ""
          @new_population.errors.full_messages.each do |msg| 
             message += " , " + msg
         end 
          return rendsaved_countryer_error(error: "saving population", message: message, status: :unprocessable_entity)
        end
        # new_country.populations << new_population
      end

    end 
  end

   # render array of country records
  def render_countries(data: country_data, message: '')
  
   render_json(status: :ok, message: message,
               data: CountrySerializer.new(data)
              .serializable_hash[:data]
              .map{|record| record[:attributes]})
  end

  def set_paging_parameters
    @page_number = 1
    @page_size = 50
    @page_number = params["page_number"].to_i if params && params["page_number"].present?
    @page_size =  params["page_size"].to_i if params && params["page_size"].present?
  end
end
