# Description:
#   Tell us the weather in a random city
#
# Dependencies:
#  n/a
#
# Configuration:
#   n/a
#
#
# Commands:
#   hubot what's the weather like - Displays the weather for place where you are not likely to be
#

citiesInWhichIsocketHasNoEmployees = [
  'london,uk'
  'cleveland'
  'utica'
  'pensacola'
  'reno'
  'minot'
  'tacoma'
  'cheyenne'
  'richmond'
  'dublin'
  'chamonix'
  'truth%20or%20consequences'
  'split'
  'sandwich'
  'eddie'
  'cody'
  'denver'
  'boston'
  'durham'
  'arlington'
  'fort%20wayne'
  'bakersfield'
  'madison'
  'chula%20vista'
  'bismarck'
  'skokie'
  'springfield'
]

http = require 'http'

getWeather = (query, cb) ->
  http.get "http://api.openweathermap.org/data/2.5/weather?q=#{query}", (res) ->
    body = ''

    res.on "data", (chunk) ->
      body += chunk

    res.on "end", () ->
      cb body

module.exports = (robot) ->
  robot.respond /what\'s\s+the\s+weather\s+like/i, (msg) ->
    getWeather msg.random(citiesInWhichIsocketHasNoEmployees), (response) ->
      weather = JSON.parse response

      # convert kelvin to farenheit
      temp = (((weather.main.temp - 273.15) * 1.8) + 32).toString().split('.')[0]

      msg.send "It's about #{temp}ºF in #{weather.name}.  #{weather.weather[0].description}."
