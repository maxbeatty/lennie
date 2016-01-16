# Description:
#   Tell what branches are on the environment
#
# Dependencies:
#  xml2js
#
# Configuration:
#   HUBOT_JENKINS_URL
#
#
# Commands:
#   hubot what's on <env> - Displays which branch is configured to be deployed to an environment for each job
#   hubot what's on <env> (for <repo>) - Displays which branch is configured to be deployed to an environment for <repo>
#
# Notes:
#   HUBOT_JENKINS_URL should have any auth inline (e.g. https://user:pass@your.jenkins.url)
JenkinsUtil = require '../lib/util/jenkins'

module.exports = (robot) ->
  jenkins = new JenkinsUtil robot

  getJobConfig = (job, re, cb) ->
    res = job.name.replace(re,'') + ': '

    jenkins.get job.url + 'config.xml', (err, resp, body) ->
      if err
        cb "Error getting config for #{res} #{err.message}"
      else
        jenkins.getBranchNameFromConfig body, (err, branch) ->
          if err
            cb res + err.message
          else
            cb res + branch

  robot.respond /what[\'\’]?s\s+on\s+([^? ]+)(\s+for\s+)?([^?]+)?.*/i, (msg) ->
    env = msg.match[1]
    preposition = msg.match[2] or ''# msg.match[2] will be " for ", if anything
    repo = msg.match[3] or ''
    summary = "Here are the branches currently on #{env + preposition + repo}: "
    requestsRemaining = 1
    re = new RegExp("-#{env}$")

    buildSummary = (body) ->
      summary += '\n\t' + body

      msg.send summary unless --requestsRemaining

    if repo.length
      # check for specific repo
      name = "#{repo}-#{env}"
      job =
        name: name
        url: "job/#{name}/"

      getJobConfig job, re, buildSummary
    else
      jenkins.getJobsMatching re, (err, jobs) ->
        if err
          msg.send "Error getting jobs: #{err.message}"
        else
          requestsRemaining = jobs.length

          for job in jobs
            getJobConfig job, re, buildSummary
