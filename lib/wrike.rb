# frozen_string_literal: true

require 'json'
require 'httparty'
require 'uri'
require 'cgi'

class Wrike
  include HTTParty
  base_uri 'https://www.wrike.com/api/v4'
  attr_reader :options

  def initialize(auth)
    @options = {
      headers: {
        'Authorization' => "bearer #{auth}",
        'User-Agent' => 'Httparty',
        'Accept' => 'application/json',
        'Content=Type' => 'application/json'
      }
    }
    super()
  end

  def folders
    JSON.parse(
      self.class.get(
        '/folders',
        options
      ).response.body,
      symbolize_names: true
    )[:data]
  end

  def create_ticket(folder_id, title)
    osjs(self.class.post("/folders/#{folder_id}/tasks", options.merge({ body: { title: title, follow: true  } })))[:data].first
  end

  def ticket(id)
    osjs(self.class.get("/tasks?permalink=#{wrike_permalink(id)}", options))[:data].first
  end

  private

  def wrike_permalink(id)
    CGI.escape "https://www.wrike.com/open.htm?id=#{id}"
  end

  def osjs(response)
    JSON.parse(response.body, symbolize_names: true)
  end
end
