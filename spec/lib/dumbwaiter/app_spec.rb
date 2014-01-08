require "spec_helper"

describe Dumbwaiter::App do
  let(:fake_opsworks) { Dumbwaiter::Mock.new }
  let(:fake_stack) { fake_opsworks.create_stack }
  let(:fake_custom_recipes) { {setup: ["ham"]} }
  let(:app_source) { Hashie::Mash.new(url: "git@example.com:tacos/great.git") }
  let!(:fake_app) { fake_opsworks.create_app(stack_id: fake_stack.stack_id, name: "goose", app_source: app_source) }
  let(:real_stack) { Dumbwaiter::Stack.new(fake_stack, fake_opsworks) }

  subject(:app) { Dumbwaiter::App.new(real_stack, fake_app, fake_opsworks) }

  its(:id) { should == fake_app.app_id }
  its(:name) { should == "goose" }
  its(:url) { should == "git@example.com:tacos/great.git" }

  describe "#revision" do
    context "when there is no revision specified" do
      let(:app_source) { {url: "git@example.com:tacos/great.git", revision: nil} }

      its(:revision) { should == "master" }
    end

    context "when a revision is specified" do
      let(:app_source) { {url: "git@example.com:tacos/great.git", revision: "wat"} }

      its(:revision) { should == "wat" }
    end
  end

  describe "#deploy" do
    context "when no revision is specified" do
      it "creates a deployment" do
        fake_opsworks.should_receive(:create_deployment) do |params|
          params[:stack_id].should == fake_stack.stack_id
          params[:app_id].should == fake_app.app_id
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
        params[:stack_id].should == fake_stack.stack_id
        params[:app_id].should == fake_app.app_id
        params[:command].should == {name: "rollback"}
      end
      app.rollback
    end
  end

  describe ".all" do
    it "fetches all the apps" do
      fake_opsworks.should_receive(:describe_apps).with(stack_id: fake_stack.stack_id).and_call_original
      Dumbwaiter::App.all(real_stack, fake_opsworks).should have(1).app
    end
  end

  describe ".find" do
    context "when the app exists" do
      it "finds the app by name" do
        Dumbwaiter::App.find(real_stack, "goose", fake_opsworks).id.should == fake_app.app_id
      end
    end

    context "when the app does not exist" do
      it "blows up" do
        expect {
          Dumbwaiter::App.find(real_stack, "teeth", fake_opsworks)
        }.to raise_error(Dumbwaiter::App::NotFound)
      end
    end
  end

  describe ".find" do
    context "when the app exists" do
      it "finds the app by id" do
        Dumbwaiter::App.find_by_id(real_stack, fake_app.app_id, fake_opsworks).name.should == "goose"
      end
    end

    context "when the app does not exist" do
      it "blows up" do
        expect {
          Dumbwaiter::App.find_by_id(real_stack, "teeth", fake_opsworks)
        }.to raise_error(Dumbwaiter::App::NotFound)
      end
    end
  end
end
