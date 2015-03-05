# Description:
#   Build word clouds
#
# Commands:
#   hubot wordcloud user - display a wordcloud
 
module.exports = (robot) ->
	robot.hear /wordcloud ([\w]*)/i, (msg) ->
    user = msg.match[1].toLowerCase()
    map = robot.brain.get(user) || {}

    sortable = []
    for k,v of map
      sortable.push [k, v]
    sortable.sort (a,b) -> return b[1] - a[1]

    message = ''
    for s in sortable
      for num in [0..s[1]-1]
        if message.length < 1800
          message += s[0]
          message += ' '
        else
          break

    msg
      .http("https://api-ssl.bitly.com/v3/shorten")
      .query
        access_token: process.env.HUBOT_BITLY_ACCESS_TOKEN
        longUrl: 'http://www.jasondavies.com/wordcloud/#' + encodeURIComponent(message)
        format: "json"
      .get() (err, res, body) ->
        response = JSON.parse body
        msg.send if response.status_code is 200 then response.data.url else response.status_txt

  robot.hear /(.*)/i, (msg) ->
    user = msg.envelope.user.name.toLowerCase()
    message = msg.match[0]
    if message?
      words = message.replace(/[^\w\s]/gi, ' ').split(' ')
      map = robot.brain.get(user) || {}
      for w in words
        map[w] ?= 0
        map[w] += 1

      robot.brain.set user, map


