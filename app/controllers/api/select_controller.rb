module Api
  class SelectController < ApiController
    before_action :foo, only: [:show, :create, :update]

    def ninja
    end

    def show
      render partial: 'show'
    end

    def edit
      puts "+++++++++++++++++++ edit"
    end

    def create
      # render_unprocessable_entity
      # puts "xxxxxxxxxx> create called, params: #{params}\n and the new option is: #{params[:option]}"
      # puts "zzzzzzzzzz> select: #{params[:options].select["select"]}"

      @option = OpenStruct.new(
        option: params[:option],
        id: SecureRandom.uuid,
        service_id: params[:service_id],
        component_id: params[:component_id]
      )
      # respond_to do |format|
      #   format.turbo_stream
      #   # format.html { render plain: "I'm like everyone else." }
      # end
    end

    def update
      @option = params[:option]
    end

    private

    def render_unprocessable_entity
      render partial: 'show', status: :unprocessable_entity, layout: false
    end

    def foo
      puts "xxxxxxxxxx> foo called, params: #{params}"
      # puts "yyyyyyyyyy> components: #{JSON.parse params["format"]}"
      if params["format"]
        puts "zzzzzzzzzz> components: #{JSON.parse(params["format"])['items']}"
        @component = JSON.parse(params["format"], object_class: OpenStruct)
      end
    end
  end
end
