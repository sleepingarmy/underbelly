require 'net/http'
require 'json'
require 'pry'

class Application

  def get_user_input
    puts "Enter the names of the teams you want to search for (i.e. Underbelly, Dribbble)."
    teams = gets.chomp
    teams.split(', ').each do |team|
      team = team.split(' ').join if team.match(/\s/)
      dribbble_query(team)
    end
  end

  def dribbble_query(team)
    params = { access_token: ENV['DRIBBBLE_ACCESS_TOKEN'] }

    #gets the team members
    members_uri = URI("https://api.dribbble.com/v1/teams/" + team + "/members?")
    members_uri.query = URI.encode_www_form(params)
    members_res = Net::HTTP.get_response(members_uri)
    members_response = JSON.parse(members_res.body)

    # gets the first member and their team
    user = members_response.first["id"].to_s
    team_uri = URI("https://api.dribbble.com/v1/users/" + user + "/teams?")
    team_uri.query = URI.encode_www_form(params)
    team_res = Net::HTTP.get_response(team_uri)
    team_response = JSON.parse(team_res.body)

    followers = team_response.first["followers_count"].to_s
    save_teams_to_txt_file(team, followers)
  end

  def save_teams_to_txt_file(team, followers)
    File.open("teams.txt", "a+") { |file| file.puts( "Team: " + team + " | Followers: " + followers ) }
    File.readlines("teams.txt").each { |line| puts line }
  end

end

application = Application.new
application.get_user_input
