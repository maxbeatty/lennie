# Description:
#   Change branch that is deployed to a playground for a repository
#
# Dependencies:
#  xml2js
#
# Configuration:
#   HUBOT_JENKINS_URL
#
# Commands:
#   hubot put <branch> on <playground> for <repo> - deploys a branch to playground for a repository (e.g. put feature on playground1 for iris)
#   hubot clean up <playground> - changes all repositories to master branch on playground
#
# Notes:
#   HUBOT_JENKINS_URL should have any auth inline (e.g. https://user:pass@your.jenkins.url)
JenkinsUtil = require '../lib/util/jenkins'

module.exports = (robot) ->
  jenkins = new JenkinsUtil robot

  updateConfig = (url, name, branch, send) ->
    prefix = "[jenkins][#{name}]"
    log = (msg) -> robot.logger.info "#{prefix} #{msg}"
    cb = (msg) -> send "#{prefix} #{msg}"

    log 'getting config.xml'
    jenkins.get url + 'config.xml', (err, res, body) ->
      if err
        cb "error getting config: #{err.message}"
      else
        jenkins.setBranchNameInConfig body, branch, (err, xml) ->
          if err
            cb "error getting branch name: #{err.message}"
          else
            log 'putting modified config.xml back'

            jenkins.post url + 'config.xml', xml, (err, res, body) ->
              if err
                cb 'error posting new config: ' + err.message
              else
                log 'queuing build'
                jenkins.post url + 'build', (err, res, body) ->
                  if err
                    cb 'error triggering new build: ' + err.message
                  else
                    if res.statusCode is 201
                      cb 'branch configured and queued to build!'
                    else
                      cb 'error unexpected response: ' + res.statusCode

  robot.respond /clean up (playground[\d]?).*$/i, (msg) ->
    env = msg.match[1].trim()
    jenkins.getJobsMatching new RegExp("-#{env}$"), (err, jobs) ->
      if err
        msg.send "Error getting jobs: #{err.message}"
      else
        reqsTodo = 0

        for job in jobs
          ++reqsTodo
          updateConfig job.url, job.name, 'master', (r) ->
            msg.send r
            msg.send 'All done!' unless --reqsTodo

  robot.respond /put (.+) on (playground[\d]?) for (.+).*$/i, (msg) ->
    branch = msg.match[1]
    env = msg.match[2]
    repo = msg.match[3].trim()
    url = "job/#{repo}-#{env}/"

    updateConfig url, repo, branch, msg.send.bind(msg)
