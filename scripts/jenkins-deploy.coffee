# Description:
#   Turn deploy jobs off and on
#
# Dependencies:
#  N/A
#
# Configuration:
#   HUBOT_JENKINS_URL
#
# Commands:
#   hubot turn off deploys - Disables all deploy jobs
#   hubot turn on deploys - Enables all deploy jobs
#   hubot turn off deploys for <repo> - Disables deploy job for repository
#   hubot turn on deploys for <repo> - Enables deploy job for repository
#
# Notes:
#   HUBOT_JENKINS_URL should have any auth inline (e.g. https://user:pass@your.jenkins.url)

module.exports = (robot) ->
  robot.respond /turn (off|on) deploys( for (.+))?.*$/i, (msg) ->
    cmd = if msg.match[1] is 'off' then 'disable' else 'enable'
    job = msg.match[3]
    turnedOff = 0
    requestsRemaining = 0

    toggle = (url) ->
      robot.http(url + cmd).post() (err, res, body) ->
        if err
          robot.emit 'error', e
          msg.send 'Jenkins says: ' + err
        else
          turnedOff++
          msg.send "Turned off #{turnedOff} deploy jobs" unless --requestsRemaining

    if job
      # turning off individual job
      requestsRemaining = 1
      toggle process.env.HUBOT_JENKINS_URL + 'job/' + job.trim()
    else
      # get jobs
      robot.http(process.env.HUBOT_JENKINS_URL + 'api/json').get() (err, res, body) ->
        if err
          robot.emit 'error', e
          msg.send 'Jenkins says: ' + err
        else
          content = JSON.parse body
          requestsRemaining = content.jobs.length

          # turn them off one by one
          for job in content.jobs when /-deploy$/.test job.name
            toggle job.url
