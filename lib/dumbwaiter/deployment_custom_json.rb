require "hashie"
require "json"

class Dumbwaiter::DeploymentCustomJson < Hashie::Mash
  def self.from_json(json_string)
    new(JSON.parse(json_string))
  end

  def self.create(name, ref)
    {deploy: {name => {scm: {revision: ref}}}}
  end

  def app_name
    self.deploy.keys.first unless self.deploy.nil?
  end

  def git_ref
    if self.app_name.nil?
      "HEAD"
    else
      self.deploy[self.app_name].scm.revision
    end
  end
end
