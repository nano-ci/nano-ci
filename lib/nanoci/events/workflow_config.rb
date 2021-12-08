# frozen_string_literal: true

require 'nanoci/events/subscriber'
require 'nanoci/events/subscriptions'
require 'nanoci/events/topics'

module Nanoci
  module Events
    class WorkflowConfig
      class << self
        # Configures topics and subscriptions. Attaches subscriptions to related topics.
        # @param topic_factory [Nanoci::Messaging::TopicFactory]
        # @param subscription_factory [Nanoci::Messaging::SubscriptionFactory]
        def setup_topics_and_subscriptions(topic_factory, subscription_factory)
          execute_job_topic = topic_factory.create_topic(Topics::EXECUTE_JOB)

          execute_job_sub = subscription_factory.create_subscription(Subscriptions::EXECUTE_JOB)
          execute_job_topic.attach(execute_job_sub)

          job_finished_topic = topic_factory.create_topic(Topics::JOB_FINISHED)

          job_finished_sub = subscription_factory.create_subscription(Subscriptions::JOB_FINISHED)
          job_finished_topic.attach(job_finished_sub)
        end
      end
    end
  end
end
