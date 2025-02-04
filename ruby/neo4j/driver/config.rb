# frozen_string_literal: true

module Neo4j
  module Driver
    class Config < Hash
      include Ext::ConfigConverter
      # class TrustStrategy
      #   class << self
      #     def trust_all_certificates; end
      #   end
      # end
      TrustStrategy = Java::OrgNeo4jDriver::Config::TrustStrategy

      def initialize(**config)
        merge!(self.class.default_config).merge!(config.compact).merge!(java_config: to_java_config(org.neo4j.driver.Config, config))
      end

      def java_config
        fetch(:java_config)
      end

      class << self
        def default_config
          {
            logger: ActiveSupport::Logger.new(STDOUT, level: ::Logger::ERROR), # :set_log
            leaked_session_logging: false,
            #connection_liveness_check_timeout: -1, # Not configured
            max_connection_lifetime: 1.hour, # :set_max_connection_life_time
            max_connection_pool_size: 100, #:set_max_pool_size
            connection_acquisition_timeout: 1.minute, #:set_max_connection_acquisition_time
            encryption: false, # :set_transport
            trust_strategy: :trust_all_certificates,
            connection_timeout: 30.seconds, # BoltSocketOptions_set_connect_timeout
            max_transaction_retry_time: Internal::Retry::ExponentialBackoffRetryLogic::DEFAULT_MAX_RETRY_TIME,
            #resolver: nil # :set_address_resolver
            keep_alive: true, # BoltSocketOptions_set_keep_alive
            # ???? BoltConfig_set_user_agent
            fetch_size: 1000,
          }
        end
      end
    end
  end
end
