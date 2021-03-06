require_domain_file

describe ManageIQ::Automate::Service::Generic::StateMachines::GenericLifecycle::Start do
  let(:admin) { FactoryGirl.create(:user_admin) }
  let(:request) { FactoryGirl.create(:service_template_provision_request, :requester => admin) }
  let(:ansible_tower_manager) { FactoryGirl.create(:automation_manager) }
  let(:job_template) { FactoryGirl.create(:ansible_configuration_script, :manager => ansible_tower_manager) }
  let(:service_ansible_tower) { FactoryGirl.create(:service_ansible_tower, :job_template => job_template) }
  let(:task) { FactoryGirl.create(:service_template_provision_task, :destination => service_ansible_tower, :miq_request => request) }
  let(:svc_task) { MiqAeMethodService::MiqAeServiceServiceTemplateProvisionTask.find(task.id) }
  let(:svc_service) { MiqAeMethodService::MiqAeServiceServiceAnsibleTower.find(service_ansible_tower.id) }
  let(:root_object) { Spec::Support::MiqAeMockObject.new('service' => svc_service, 'service_action' => 'Provision') }
  let(:ae_service) { Spec::Support::MiqAeMockService.new(root_object) }

  context "Start" do
    it "creates notification " do
      allow(ae_service).to receive(:create_notification)

      described_class.new(ae_service).main
      expect(ae_service.root['ae_result']).to eq("ok")
    end
  end
end
