require 'net/http'
require 'json'
require 'pry'

class Application

  def get_user_input
    puts "Enter the names of the teams you want to search for (i.e. Underbelly, Dribbble), or type \"exit\" to quit."
    teams = gets.chomp.downcase
    exit if teams == "exit"
    teams.split(', ').each do |team|
      team = team.split(' ').join if team.match(/\s/)
      dribbble_query(team)
    end
  end

  def dribbble_query(team)
    params = { access_token: ENV['DRIBBBLE_ACCESS_TOKEN'] }

    #gets the team members
    members_uri = URI("https://api.dribbble.com/v1/teams/#{team}/members?")
    members_uri.query = URI.encode_www_form(params)
    members_res = Net::HTTP.get_response(members_uri)
    # returns <Net::HTTPNotFound 404 Not Found readbody=true> if team name is invalid
    at_exit { get_user_input }
    abort ("No team matches the name \"#{team}\".  Please enter a valid team name.") if members_res.class == Net::HTTPNotFound
    members_response = JSON.parse(members_res.body)

    # gets the first member and their teams, which will include the team searched for
    user = members_response.first["id"]
    team_uri = URI("https://api.dribbble.com/v1/users/#{user}/teams?")
    team_uri.query = URI.encode_www_form(params)
    team_res = Net::HTTP.get_response(team_uri)
    team_response = JSON.parse(team_res.body)

    # get followers based on the team response where the name == team
    get_followers(team, team_response)
    save_teams_to_txt_file(team, @followers)
  end

  def get_followers(team, response)
    response.each { |t|  @followers = t["followers_count"].to_s if t["name"].downcase == team }
  end

  def save_teams_to_txt_file(team, followers)
    File.open("teams.txt", "a+") { |file| file.puts( "Team: #{ team.capitalize } | Followers: #{followers}" ) }
    File.readlines("teams.txt").each { |line| puts line }
  end

end

application = Application.new
application.get_user_input
