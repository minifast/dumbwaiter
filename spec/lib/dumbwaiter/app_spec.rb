require "spec_helper"

describe Dumbwaiter::App do
  let(:fake_stack) { double(:stack, id: "pancakes") }
  let(:fake_app) { double(:app, name: "goose", app_id: "amazing") }
  let(:fake_apps) { double(:apps, apps: [fake_app]) }
  let(:fake_opsworks) { double(:opsworks, describe_apps: fake_apps) }

  subject(:app) { Dumbwaiter::App.new(fake_stack, fake_app, fake_opsworks) }

  its(:stack) { should == fake_stack }
  its(:opsworks_app) { should == fake_app }
  its(:id) { should == "amazing" }
  its(:name) { should == "goose" }

  describe "#deploy" do
    context "when no revision is specified" do
      it "creates a deployment" do
        fake_opsworks.should_receive(:create_deployment) do |params|
          params[:stack_id].should == "pancakes"
          params[:app_id].should == "amazing"
          params[:command].should == {name: "deploy", args: {migrate: ["true"]}}
        end
        app.deploy
      end
    end

    context "when a revision is specified" do
      it "creates a deployment with a revision" do
        fake_opsworks.should_receive(:create_deployment) do |params|
          params[:custom_json].should == {deploy: {"goose" => {scm: {revision: "golden"}}}}.to_json
        end
        app.deploy("golden")
      end
    end
  end

  describe "#rollback" do
    it "creates a rollback" do
      fake_opsworks.should_receive(:create_deployment) do |params|
        params[:stack_id].should == "pancakes"
        params[:app_id].should == "amazing"
        params[:command].should == {name: "rollback"}
      end
      app.rollback
    end
  end

  describe ".all" do
    it "fetches all the apps" do
      fake_opsworks.should_receive(:describe_apps).with(stack_id: "pancakes")
      Dumbwaiter::App.all(fake_stack, fake_opsworks).should have(1).app
    end
  end

  describe ".find" do
    context "when the app exists" do
      it "finds the app by name" do
        Dumbwaiter::App.find(fake_stack, "goose", fake_opsworks).id.should == "amazing"
      end
    end

    context "when the app does not exist" do
      it "blows up" do
        expect {
          Dumbwaiter::App.find(fake_stack, "teeth", fake_opsworks)
        }.to raise_error(Dumbwaiter::App::NotFound)
      end
    end
  end
end
