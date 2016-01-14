# Description:
#   Change branch that is deployed to a playground for a repository
#
# Dependencies:
#  xml2json
#
# Configuration:
#   HUBOT_JENKINS_URL
#
# Commands:
#   hubot put <branch> on <playground> for <repo> - deploys a branch to playground for a repository (e.g. put feature on playground1 for iris)
#
# Notes:
#   HUBOT_JENKINS_URL should have any auth inline (e.g. https://user:pass@your.jenkins.url)
parser = require 'xml2json'

module.exports = (robot) ->
  robot.respond /put (.+) on (.+) for (.+).*$/i, (msg) ->
    branch = msg.match[1]
    env = msg.match[2]
    repo = msg.match[3].trim()
    url = "#{process.env.HUBOT_JENKINS_URL}job/#{repo}-#{env}/"

    robot.http(url + 'config.xml').get() (err, res, body) ->
      if err
        robot.emit 'error', e
        msg.send 'Jenkins says: ' + err
      else
        try
          json = parser.toJson body, { object: true }

          switch
            when json.project
              json.project.scm.branches['hudson.plugins.git.BranchSpec'].name = branch
            when json['maven2-moduleset']
              json['maven2-moduleset'].scm.branches['hudson.plugins.git.BranchSpec'].name = branch
            else
              return msg.send 'Um. Not sure how to update the branch for this repository.'

          xml = parser.toXml json
        catch e
          robot.emit 'error', e
          msg.send 'Error when trying to update the config: ' + e.message

        robot.http(url + 'config.xml').header('Content-Type', 'text/xml').post(xml) (err, res, body) ->
          if err
            robot.emit 'error', err
            msg.send 'Error posting new config: ' + err.message
          else
            robot.http(url + 'build').post() (err, res, body) ->
              if err
                robot.emit 'error', err
                msg.send 'Error triggering new build: ' + err.message
              else
                if res.statusCode is 201
                  msg.send 'Branch configured and queued to build!'
                else
                  msg.send 'Got unexpected response status code: ' + res.statusCode
