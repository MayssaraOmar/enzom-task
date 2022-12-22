class CountrySerializer
    include FastJsonapi::ObjectSerializer
  
    attribute  :country_id do |object|
      object&.id
    end
  
    attributes :name,
               :city_name
  
    attribute :populations  do |object|
        PopulationSerializer.new(object.populations)
                                    .serializable_hash[:data]
                                    .map{|record| record[:attributes]}
    end
end