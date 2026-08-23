module Api
  module V1
    class ReactionsController < ApplicationController
      before_action :set_post, only: [:index, :create]
      before_action :authenticate_user!, only: [:create, :destroy]

      def index
        reactions = @post.reactions
                         .includes(:user)
                         .order(created_at: :desc)

        render json: reactions.map { |reaction| reaction_json(reaction) }
      end

      def create
        reaction = @post.reactions.find_or_initialize_by(
          user: current_user
        )
        created = reaction.new_record?

        reaction.kind = reaction_params[:kind] || :like

        if reaction.save
          render json: reaction_json(reaction), status: created ? :created : :ok
        else
          render json: {
            errors: reaction.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def destroy
        reaction = current_user.reactions.find(params[:id])
        reaction.destroy!

        head :no_content
      end

      private

      def set_post
        @post = Post.find(params[:post_id])
      end

      def reaction_params
        params.require(:reaction).permit(:kind)
      end

      def reaction_json(reaction)
        {
          id: reaction.id,
          kind: reaction.kind,
          created_at: reaction.created_at,
          user: {
            id: reaction.user.id,
            name: reaction.user.name
          }
        }
      end
    end
  end
end
