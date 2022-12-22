require 'dotenv'
require 'json'
require 'fast_inserter'
Dotenv.load

include ResponseHelper
include CountriesHelper

class CountriesController < ApplicationController
  before_action :set_paging_parameters ,only: [:index]

  def index
    @countries = Country.all.paginate(page: @page_number, per_page: @page_size)
    render_countries(data: @countries)
  end

  def show_country_data
    @country = Country.find_by(name: params[:country_name])
    puts(@country)
    render_country(data: @country)
  end

  def sync
    @response =  RestClient.get "https://countriesnow.space/api/v0.1/countries/population", {content_type: :json, accept: :json, "user-key": ENV["API_KEY"]}
    @data = JSON.parse(@response.body)["data"]
    
    new_populations = []
    @countries = @data.map do |country|
      @existing_country = Country.find_by(:name=>country["country"])
      if !@existing_country
        @new_country = Country.new(:name => country["country"], :code => country["code"], :iso3 => country["iso3"])
        if !@new_country.save
          render_error_full_error_messages(@new_country.errors.full_messages, "Saving Country")
        end
        @existing_country = Country.find_by(:name=>country["country"])
      end
      
      @populations = country["populationCounts"].map do |population|        
        @population = Population.find_by(:country_id => @existing_country.id, :year=>population["year"])
       
        if !@population
          if(!population["year"] || !population["value"])
            render_error_full_error_messages("year, count or both are null", "Saving Population")
          end
          new_populations << [@existing_country.id, population["year"].to_i, population["value"].to_i]

        elsif @population.count != population["value"].to_i
          @population.assign_attributes(:count => population["value"].to_i)
          if !@population.save
            render_error_full_error_messages(@new_population.errors.full_messages, "Saving Population")
          end
        end
      end
    end

    inserter = FastInserter::Base.new(populations_fast_inserter_params(new_populations))
    inserter.fast_insert
  end

  def init
    @response =  RestClient.get "https://countriesnow.space/api/v0.1/countries/population", {content_type: :json, accept: :json, "user-key": ENV["API_KEY"]}
    @data = JSON.parse(@response.body)["data"]
    # to fast insert
    populations = []
    @countries = @data.map do |country|
      @new_country = Country.new(:name => country["country"], :code => country["code"], :iso3 => country["iso3"])
      if !@new_country.save
        render_error_full_error_messages(@new_country.errors.full_messages, "Saving Country")
      end
      @new_country = Country.find_by(:name=>country["country"])

      @populations = country["populationCounts"].map do |population|
        if(!population["year"] || !population["value"])
          render_error_full_error_messages("year, count or both are null", "Saving Population")
        end
        populations << [@new_country.id, population["year"].to_i, population["value"].to_i]
      end
    end

    inserter = FastInserter::Base.new(populations_fast_inserter_params(populations))
    inserter.fast_insert
  end

  def populations_fast_inserter_params(populations)
    params = {
      table: 'populations',
      static_columns: {
      },
      additional_columns: {
        
      },
      options: {
        timestamps: true,
        unique: true,
        check_for_existing: false
      },
      group_size: 2_000,
      variable_column: %w(country_id year count),
      values: populations
    }
  end


  # def country_params
  #   params.require(:data).permit(:country, :city)
  # end

  # def population_params
  #   params.require(:populationCount).permit(:year, :count, :sex, :reliabilty)
  # end

  def set_paging_parameters
    @page_number = 1
    @page_size = 50
    @page_number = params["page_number"].to_i if params && params["page_number"].present?
    @page_size =  params["page_size"].to_i if params && params["page_size"].present?
  end
end
