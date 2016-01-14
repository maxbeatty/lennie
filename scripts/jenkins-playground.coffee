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
URL  = require 'url'
jenkinsUrl  = URL.parse process.env.HUBOT_JENKINS_URL
xml2js = require 'xml2js'
JENKINS_IS_STUPID = ''

module.exports = (robot) ->
  updateConfig = (url, branch, send) ->
    [repo, env] = URL.parse(url).path.split('/')[2].split('-')
    prefix = "[jenkins][#{env}][#{repo}]"
    log = (msg) -> robot.logger.info "#{prefix} #{msg}"
    cb = (msg) -> send "#{prefix} #{msg}"

    log 'getting config.xml'
    robot.http(url + 'config.xml').auth(jenkinsUrl.auth).get() (err, res, body) ->
      if err
        cb 'Jenkins says: ' + err
      else
        try
          parser = new xml2js.Parser()
          parser.parseString body, (err, json) ->
            if err
              robot.logger.error err
            else
              switch
                when json.project
                  j = json.project.scm[0].branches[0]['hudson.plugins.git.BranchSpec'][0]
                when json['maven2-moduleset']
                  j = json['maven2-moduleset'].scm[0].branches[0]['hudson.plugins.git.BranchSpec'][0]
                else
                  return cb 'Um. Not sure how to update the branch for this repository.'

              if j.name[0] is branch
                return cb branch + ' is already configured'
              else
                j.name = [branch]

              builder = new xml2js.Builder()
              xml = builder.buildObject json

              log 'putting modified config.xml back'

              robot.http(url + 'config.xml')
                .auth(jenkinsUrl.auth)
                .header('Content-Type', 'text/xml')
                .post(xml) (err, res, body) ->
                  if err
                    cb 'Error posting new config: ' + err.message
                  else
                    log 'queuing build'
                    robot.http(url + 'build').auth(jenkinsUrl.auth).post(JENKINS_IS_STUPID) (err, res, body) ->
                      if err
                        cb 'Error triggering new build: ' + err.message
                      else
                        if res.statusCode is 201
                          cb 'Branch configured and queued to build!'
                        else
                          cb 'Got unexpected response status code: ' + res.statusCode
        catch e
          return cb 'Error when trying to update the config: ' + e.message

  robot.respond /clean up (playground[\d]?).*$/i, (msg) ->
    robot.http(process.env.HUBOT_JENKINS_URL + 'api/json')
      .auth(jenkinsUrl.auth)
      .header('Accept', 'application/json')
      .get() (err, res, body) ->
        if err
          msg.send 'Jenkins says: ' + err
        else
          content = JSON.parse body
          reqsTodo = 0
          re = new RegExp "-#{msg.match[1].trim()}$"

          for job in content.jobs when re.test job.name
            ++reqsTodo
            updateConfig job.url, 'master', (r) ->
              msg.send r
              msg.send 'All done!' unless --reqsTodo

  robot.respond /put (.+) on (playground[\d]?) for (.+).*$/i, (msg) ->
    branch = msg.match[1]
    env = msg.match[2]
    repo = msg.match[3].trim()
    url = "#{process.env.HUBOT_JENKINS_URL}job/#{repo}-#{env}/"

    updateConfig url, branch, msg.send.bind(msg)
