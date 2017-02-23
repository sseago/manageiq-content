#
# Description: This class calls a refresh
#

module ManageIQ
  module Automate
    module Service
      module Generic
        module StateMachines
          module GenericLifecycle
            class Refresh
              def initialize(handle = $evm)
                @handle = handle
              end

              def main
                @handle.log(:info, "Starting Refresh")

                begin
                  service.refresh(service_action)
                  @handle.root['ae_result'] = 'ok'
                rescue => err
                  @handle.root['ae_result'] = 'error'
                  @handle.root['ae_reason'] = err.message
                  @handle.log(:error, "Error in Refresh: #{err.message}")
                  update_task(err.message)
                end
                @handle.log(:info, "Ending Refresh")
              end

              private

              def update_task(message)
                return unless service_action == 'Provision'
                @handle.root["service_template_provision_task"].tap do |task|
                  if task.nil?
                    @handle.log(:error, 'service_template_provision_task is nil')
                    raise "service_template_provision_task not found"
                  end
                  task.miq_request.user_message = message
                end
              end

              def service
                @handle.root["service"].tap do |service|
                  if service.nil?
                    @handle.log(:error, 'Service is nil')
                    raise 'Service not found'
                  end
                end
              end

              def service_action
                @handle.root["service_action"].tap do |action|
                  unless %w(Provision Retirement Reconfigure).include?(action)
                    @handle.log(:error, "Invalid service action: #{action}")
                    raise "Invalid service_action"
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  ManageIQ::Automate::Service::Generic::StateMachines::GenericLifecycle::Refresh.new.main
end
