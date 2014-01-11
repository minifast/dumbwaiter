require "spec_helper"

describe Dumbwaiter::UserProfile do
  let(:fake_user_profile) { double(:user_profile, iam_user_arn: "schwarz", name: "conan") }
  let(:fake_user_profiles) { double(:user_profiles, user_profiles: [fake_user_profile])}
  let(:fake_opsworks) { double(:opsworks, describe_user_profiles: fake_user_profiles) }

  subject(:user_profile) { Dumbwaiter::UserProfile.new(fake_user_profile, fake_opsworks) }

  its(:opsworks_user_profile) { should == fake_user_profile }
  its(:iam_user_arn) { should == "schwarz" }
  its(:name) { should == "conan" }

  describe ".find" do
    it "finds a user profile for the given iam user arn" do
      fake_opsworks.should_receive(:describe_user_profiles).with(iam_user_arns: ["schwarz"])
      Dumbwaiter::UserProfile.find("schwarz", fake_opsworks).should == fake_user_profile
    end

    it "caches duplicate requests for the same arn" do
      fake_opsworks.should_receive(:describe_user_profiles).once
      Dumbwaiter::UserProfile.find("schwarz", fake_opsworks)
      Dumbwaiter::UserProfile.find("schwarz", fake_opsworks)
    end

    context "when the incoming user arn is nil" do
      it "returns nil" do
        Dumbwaiter::UserProfile.find(nil, fake_opsworks).should be_nil
      end

      it "does not ask opsworks for the user profile" do
        fake_opsworks.should_not_receive(:describe_user_profiles)
        Dumbwaiter::UserProfile.find(nil, fake_opsworks)
      end
    end
  end
end
