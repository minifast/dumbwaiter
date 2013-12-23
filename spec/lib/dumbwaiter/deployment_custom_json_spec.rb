require "spec_helper"

describe Dumbwaiter::DeploymentCustomJson do
  subject(:json) { Dumbwaiter::DeploymentCustomJson.new(custom_json) }

  context "when the custom json does not contain a revision" do
    let(:custom_json) { {} }

    its(:app_name) { should be_nil }
    its(:revision) { should be_nil }
  end

  context "when the custom json contains a revision" do
    let(:custom_json) { {deploy: {"reifel" => {scm: {revision: "corn"}}}} }

    its(:app_name) { should == "reifel" }
    its(:revision) { should == "corn" }
  end

  describe ".create" do
    let(:json) { Dumbwaiter::DeploymentCustomJson.create("socks", "ham") }

    specify { json.should == {deploy: {"socks" => {scm: {revision: "ham"}}}} }
  end

  describe ".from_json" do
    let(:json_string) { JSON.dump(deploy: {"toes" => {scm: {revision: "jam"}}}) }
    subject(:json) { Dumbwaiter::DeploymentCustomJson.from_json(json_string) }

    its(:app_name) { should == "toes" }
    its(:revision) { should == "jam" }
  end
end
