class Conversations::ActivityMessageJob < ApplicationJob
  queue_as :high

  def perform(conversation, message_params, skip_last_activity_update: false)
    Current.skip_conversation_last_activity_update = skip_last_activity_update
    conversation.messages.create!(message_params)
  ensure
    Current.skip_conversation_last_activity_update = nil
  end
end
