# frozen_string_literal: true

require 'nanoci/events/subscriptions'
require 'nanoci/messaging/subscriber'
require 'nanoci/mixins/logger'

module Nanoci
  module Events
    class JobFinishedSubscriber < Nanoci::Messaging::Subscriber
      include Nanoci::Mixins::Logger

      # Initializes new object of [JobFinishedSubscriber]
      # @param pipeline_engine [Nanoci::PipelineEngine]
      # @param topic_factory [Nanoci::Messaging::TopicFactory]
      # @param subscription_factory [Nanoci::Messaging::SubscriptionFactory]
      def initialize(pipeline_engine, subscription_factory)
        @pipeline_engine = pipeline_engine

        subscription = subscription_factory.create_subscription(Subscriptions::JOB_FINISHED)

        super(subscription)
      end

      # Handles event ExecuteJobEvent
      # @param msg [Nanoci::Events::JobFinishedEvent]
      def handle_message(msg)
        @pipeline_engine.finalize_job(msg.stage, msg.job, msg.outputs, msg.success)
      end
    end
  end
end
