module ResponseHelper
    def render_json(data: {}, message: "", status: :ok)
        puts "entered response helper"
        return render json: {
            data: data,
            message: message
        }, status: status
    end

    def render_error(data: nil, error: {}, message: "", status: :unprocessable_entity)
        if data.nil?
            return render json: {
                error: error,
                message: message
            }, status: status
        else
            return render json: {
                data: data, 
                error: error,
                message: message
            }, status: status
        end
    end
end
