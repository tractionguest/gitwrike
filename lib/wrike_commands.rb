require 'facets/string/snakecase'
require 'facets/string/squish'
require_relative 'wrike.rb'

class WrikeCommands
  def initialize(config_file)
    @config = JSON.parse(config_file.read, symbolize_names: true)
  end

  def cmd_from_permalink(permalink)
    byebug
    create_branch(permalink, sdk.ticket(permalink)[:title])
  end

  def cmd_from_title(title)
    res = sdk.create_ticket(@config[:folder_id], title)
    permalink = CGI::parse(URI.parse(res[:permalink]).query)["id"].first
    create_branch(permalink, title)
  end

  private

  def create_branch(permalink, title)
    title = branch_name_from_ticket_and_title(permalink, title)
    git.branch(title).checkout
  end

  def git
    @git = Git.open(".")
  end

  def branch_name_from_ticket_and_title(ticket, title)
    title = munched_string(title)[0..25]
    "feature/#{ticket}-#{title}"
  end

  def sdk
    @sdk ||= Wrike.new(@config[:auth])
  end

  def munched_string(string)
    string.snakecase
          .gsub(/[^a-zA-Z0-9 -]/, ' ')
          .squish
          .gsub(/\s/, '_')
  end
end
