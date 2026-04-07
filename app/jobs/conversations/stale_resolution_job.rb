class Conversations::StaleResolutionJob < ApplicationJob
  queue_as :scheduled_jobs

  def perform
    stale_conversations.find_each(batch_size: 100) do |conversation|
      conversation.resolved!
    end
  end

  private

  def stale_conversations
    Conversation
      .where('last_activity_at < ?', 15.days.ago)
      .where.not(status: Conversation.statuses[:resolved])
      .limit(Limits::BULK_ACTIONS_LIMIT)
  end
end
