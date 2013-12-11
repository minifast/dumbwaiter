require "spec_helper"

describe Dumbwaiter::Instance do
  let(:fake_stack) { double(:stack, id: "pancakes") }
  let(:fake_layer) { double(:layer, id: "pinto", stack: fake_stack) }

  let(:fake_instance) { double(:instance, instance_id: "dragons") }
  let(:fake_instances) { double(:instances, instances: [fake_instance]) }
  let(:fake_opsworks) { double(:opsworks, describe_instances: fake_instances) }

  subject(:instance) { Dumbwaiter::Instance.new(fake_layer, fake_instance, fake_opsworks) }

  its(:opsworks_instance) { should == fake_instance }
  its(:id) { should == "dragons" }

  describe ".all" do
    it "fetches all the instances" do
      fake_opsworks.should_receive(:describe_instances).with(layer_id: "pinto")
      Dumbwaiter::Instance.all(fake_layer, fake_opsworks).should have(1).instance
    end
  end
end
