module Api
  module Calendar
    class NeedsController < JSONAPI::ResourceController
    	before_action :authenticate_user!, only: [:ngo_index]

      def ngo_index
        if current_user && current_user.admin?
          needs = Need.all
        else
          needs = Need.where(user_id: current_user.id)
        end
        resources = needs.map { |need| NeedResource.new(need, nil) }
        json = JSONAPI::ResourceSerializer.new(NeedResource).serialize_to_hash(resources)
        render json: json
      end


      def create
        sparams = params['data']['attributes']
        start_time = sparams['start-time']
        end_time = sparams['end-time']
        user_id = current_user.id

        need = Need.create!(start_time: start_time, end_time: end_time, user_id: user_id)
        need.save

        need_json = JSONAPI::ResourceSerializer.new(NeedResource).serialize_to_hash(NeedResource.new(need, nil))
        render json: need_json
      end

      def update
        need = Need.find_by(id: params['id'])
        ::NotifyJob.new.perform(need)
        Rails.logger.debug '=========================lslslalfas'
        super
      end
    end
  end
end
