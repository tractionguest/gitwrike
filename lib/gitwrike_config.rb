
require "mixlib/cli"

class GitwrikeConfig
  extend Mixlib::Config

  log_level   :info
  config_file "config.rb"
end
