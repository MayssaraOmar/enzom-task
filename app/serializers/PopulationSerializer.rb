class PopulationSerializer
    include FastJsonapi::ObjectSerializer
  
    attribute  :population_id do |object|
      object&.id
    end
  
    attributes :year,
               :count
end