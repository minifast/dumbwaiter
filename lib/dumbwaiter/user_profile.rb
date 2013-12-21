class Dumbwaiter::UserProfile
  attr_reader :opsworks_user_profile, :opsworks

  def self.cache
    @cache ||= {}
  end

  def self.find(iam_user_arn, opsworks = Aws::OpsWorks.new(region: "us-east-1"))
    cache[iam_user_arn] ||= opsworks.describe_user_profiles(iam_user_arns: [iam_user_arn]).user_profiles.first
  end

  def initialize(opsworks_user_profile, opsworks = Aws::OpsWorks.new(region: "us-east-1"))
    @opsworks_user_profile = opsworks_user_profile
    @opsworks = opsworks
  end

  def iam_user_arn
    opsworks_user_profile.iam_user_arn
  end

  def name
    opsworks_user_profile.name
  end
end
