require 'dotenv'
require 'json'
require 'fast_inserter'
Dotenv.load

include ResponseHelper

class CountriesController < ApplicationController
  before_action :set_paging_parameters ,only: [:index]

  def index
    @countries = Country.all.paginate(page: @page_number, per_page: @page_size)
    render_countries(data: @countries)
  end

  def show_country_data
    @countries = Country.where(name: params[:country_name])
    render_countries(data: @countries)
  end

  def sync
    @response =  RestClient.get "https://countriesnow.space/api/v0.1/countries/population", {content_type: :json, accept: :json, "user-key": ENV["API_KEY"]}
    @data = JSON.parse(@response.body)["data"]
 
 
    #   @data.group_by{ |h| [h['country'],h['city'],h['country']] }.each do |loc,events|
    # puts "'#{loc.join(',')}': #{events.length} event#{:s if events.length!=1}"
    # print "--> "
    # puts events.map{ |e| e['status'] }.join(', ')
    # end

    # out = @data.groupby(['country','city'])[['populationCounts']].apply(lambda x: x.to_dict('records')).reset_index(name='populations')
    # puts(out)
    @countries = @data.map do |country|
      puts (country)
      @existing_country = Country.find_by(:name=>country["country"])
      if !@existing_country
        @new_country = Country.new(:name => country["country"], :code => country["code"], :iso3 => country["iso3"])
        if !@new_country.save
          render_error_full_error_messages(@new_country.errors.full_messages, "Saving Country")
        end
        @existing_country = Country.find_by(:name=>country["country"])
      end
      
      @populations = country["populationCounts"].map do |population|
        puts (population)
        
        @new_population = Population.new(:year => population["year"].to_i, :count => population["value"].to_i)
        @new_population.country = @existing_country
        if !@new_population.save
          render_error_full_error_messages(@new_population.errors.full_messages, "Saving Population")
        end
      end
    end
  end

  def x
    @response =  RestClient.get "https://countriesnow.space/api/v0.1/countries/population", {content_type: :json, accept: :json, "user-key": ENV["API_KEY"]}
    @data = JSON.parse(@response.body)["data"]
 
    @countries = @data.map do |country|
      puts (country)
     
      @new_country = Country.new(:name => country["country"], :code => country["code"], :iso3 => country["iso3"])
      if !@new_country.save
        render_error_full_error_messages(@new_country.errors.full_messages, "Saving Country")
      end
      @existing_country = Country.find_by(:name=>country["country"])
      
      @populations = country["populationCounts"].map do |population|
        puts (population)
        @new_population = Population.new(:year => population["year"].to_i, :count => population["value"].to_i)
        @new_population.country = @existing_country
        if !@new_population.save
          render_error_full_error_messages(@new_population.errors.full_messages, "Saving Population")
        end
      end

    end
  end

  def init
    @response =  RestClient.get "https://countriesnow.space/api/v0.1/countries/population", {content_type: :json, accept: :json, "user-key": ENV["API_KEY"]}
    @data = JSON.parse(@response.body)["data"]
     # ids to fast insert
    populations = []
    @countries = @data.map do |country|
      @new_country = Country.new(:name => country["country"], :code => country["code"], :iso3 => country["iso3"])
      if !@new_country.save
        render_error_full_error_messages(@new_country.errors.full_messages, "Saving Country")
      end
      @existing_country = Country.find_by(:name=>country["country"])

      params = {
      table: 'populations',
      static_columns: {
        country_id: @existing_country.id
      },
      additional_columns: {
        
      },
      options: {
        timestamps: true,
        unique: true,
        check_for_existing: false
      },
      group_size: 2_000,
      variable_column: %w(year count),
      values: populations
    }

      @populations = country["populationCounts"].map do |population|
        populations << [population["year"].to_i, population["value"].to_i]
      end

    inserter = FastInserter::Base.new(params)
    inserter.fast_insert

    end

    
    

  end

  # def country_params
  #   params.require(:data).permit(:country, :city)
  # end

  # def population_params
  #   params.require(:populationCount).permit(:year, :count, :sex, :reliabilty)
  # end

  def render_error_full_error_messages(errors, error_operation)
    message = ""
    errors.each do |msg| 
       message += " , " + msg
   end 
    return render_error(error: error_operation, message: message, status: :unprocessable_entity)
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
