class Conversations::PendingToOpenJob < ApplicationJob
  queue_as :low

  def perform
    Conversation
      .where(status: :pending)
      .where.not(snoozed_until: nil)
      .where(snoozed_until: 3.days.ago..Time.current)
      .find_each(batch_size: 100) do |conversation|
        conversation.open!
        # rubocop:disable Rails/SkipsModelValidations
        conversation.update_column(:snoozed_until, nil)
        # rubocop:enable Rails/SkipsModelValidations
      end
  end
end
