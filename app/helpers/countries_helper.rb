module CountriesHelper
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
    
    # render one country 
    def render_country(data: country_data, message: '')
      
        render_json(status: :ok, message: message,
                    data: CountrySerializer.new(data)
                   .serializable_hash[:data][:attributes])
    end 

    # def render_country(adata: country_data, message: '')
    #     render_json(status: :ok, message: message, data: CountrySerializer.new(country_data).serializable_hash[:data][:attributes])
    # end
end
