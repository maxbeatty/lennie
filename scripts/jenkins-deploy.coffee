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
URL  = require 'url'
jenkinsUrl  = URL.parse process.env.HUBOT_JENKINS_URL
JENKINS_IS_STUPID = ''

module.exports = (robot) ->
  robot.respond /turn (off|on) deploys( for (.+))?.*$/i, (msg) ->
    cmd = if msg.match[1] is 'off' then 'disable' else 'enable'
    job = msg.match[3]
    turnedOff = 0
    requestsRemaining = 0

    toggle = (url) ->
      ++requestsRemaining
      robot.http(url + cmd).auth(jenkinsUrl.auth).post(JENKINS_IS_STUPID) (err, res, body) ->
        if err
          robot.logger.error '[jenkins][deploy]' + err.message
          msg.send 'Jenkins says: ' + err
        else
          robot.logger.info '[jenkins][deploy]' + 'Response code: ' + res.statusCode
          robot.logger.info '[jenkins][deploy]' + 'Body: ' + body
          # 302 Found means it worked
          ++turnedOff if res.statusCode is 302

          msg.send "Turned #{msg.match[1]} #{turnedOff} deploy jobs" unless --requestsRemaining

    if job
      # turning off individual job
      robot.logger.info '[jenkins][deploy]' + "trying to #{cmd} #{job}"
      toggle process.env.HUBOT_JENKINS_URL + 'job/' + job.trim() + '-deploy/'
    else
      # get jobs
      robot.http(process.env.HUBOT_JENKINS_URL + 'api/json')
        .auth(jenkinsUrl.auth)
        .header('Accept', 'application/json')
        .get() (err, res, body) ->
          if err
            msg.send 'Jenkins says: ' + err
          else
            content = JSON.parse body

            # turn them off one by one
            for job in content.jobs when /-deploy$/.test job.name
              robot.logger.info '[jenkins][deploy]' + "trying to #{cmd} #{job.name}"
              toggle job.url
