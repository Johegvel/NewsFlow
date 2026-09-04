class ApplicationController < ActionController::API
  def current_user
    return @current_user if defined?(@current_user)

    authorization = request.headers["Authorization"].to_s
    token = authorization.match(/\ABearer\s+(.+)\z/i)&.captures&.first
    return @current_user = nil if token.blank?

    payload = JsonWebToken.decode(token)
    return @current_user = nil if payload[:sub].blank?
    return @current_user = nil if payload[:type].present? && payload[:type] != "access"

    @current_user = User.find(payload[:sub])
  rescue JWT::DecodeError, ActiveRecord::RecordNotFound
    @current_user = nil
  end

  def authenticate_user!
    return if current_user.present?

    render json: {
      error: "Token inválido o ausente"
    }, status: :unauthorized
  end

  protected

  def serialize_posts(posts)
    records = posts.to_a
    post_ids = records.map(&:id)

    comment_counts = Comment.where(post_id: post_ids).group(:post_id).count
    reaction_counts = Reaction.where(post_id: post_ids).group(:post_id).count
    reaction_ids = current_user.present? ?
      current_user.reactions.where(post_id: post_ids).pluck(:post_id, :id).to_h : {}
    saved_post_ids = current_user.present? ?
      current_user.saved_posts.where(post_id: post_ids).pluck(:post_id, :id).to_h : {}

    records.map do |post|
      serialize_post(
        post,
        comments_count: comment_counts.fetch(post.id, 0),
        reactions_count: reaction_counts.fetch(post.id, 0),
        reaction_id: reaction_ids[post.id],
        saved_post_id: saved_post_ids[post.id]
      )
    end
  end

  def serialize_post(post, comments_count:, reactions_count:, reaction_id:, saved_post_id:)
    {
      id: post.id,
      title: post.title,
      content: post.content,
      post_type: post.post_type,
      status: post.status,
      published_at: post.published_at,
      comments_count: comments_count,
      reactions_count: reactions_count,
      viewer_reaction_id: reaction_id,
      viewer_saved_post_id: saved_post_id,
      user: {
        id: post.user.id,
        name: post.user.name
      },
      community: {
        id: post.community.id,
        name: post.community.name,
        slug: post.community.slug
      }
    }
  end
end
