class Conversations::StaleResolutionJob < ApplicationJob
  queue_as :scheduled_jobs

  def perform
    stale_conversations.each do |conversation|
      conversation.resolved!
    end
  end

  private

  def stale_conversations
    Conversation
      .where('last_activity_at < ?', stale_before_time)
      .where.not(status: Conversation.statuses[:resolved])
      .limit(Limits::BULK_ACTIONS_LIMIT)
  end

  def stale_before_time
    Time.current - (auto_resolve_after_ms / 1000.0)
  end

  def auto_resolve_after_ms
    ENV.fetch('GLOBAL_AUTO_RESOLVE_AFTER_MS', 15.days.in_milliseconds).to_i
  end
end
