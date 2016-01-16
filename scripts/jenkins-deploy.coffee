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
JenkinsUtil = require '../lib/util/jenkins'

module.exports = (robot) ->
  jenkins = new JenkinsUtil robot

  robot.respond /turn (off|on) deploys( for (.+))?.*$/i, (msg) ->
    cmd = if msg.match[1] is 'off' then 'disable' else 'enable'
    job = msg.match[3]
    turnedOff = 0
    requestsRemaining = 0

    toggle = (url) ->
      ++requestsRemaining
      jenkins.post url + cmd, (err, res, body) ->
        if err
          msg.send "Error trying to #{cmd}: #{err.message}"
        else
          robot.logger.info '[jenkins][deploy] Response code: ' + res.statusCode
          # 302 Found means it worked
          ++turnedOff if res.statusCode is 302

          unless --requestsRemaining
            msg.send "Turned #{msg.match[1]} #{turnedOff} deploy jobs"

    if job
      # turning off individual job
      robot.logger.info "[jenkins][deploy] trying to #{cmd} #{job}"
      toggle "job/#{job.trim()}-deploy/"
    else
      jenkins.getJobsMatching /-deploy$/, (err, jobs) ->
        if err
          msg.send "Error getting jobs: #{err.message}"
        else
          # turn them off one by one
          for job in jobs
            robot.logger.info "[jenkins][deploy] trying to #{cmd} #{job.name}"
            toggle job.url
