const Code = require('code')
const Lab = require('lab')
const Helper = require('hubot-test-helper')
const nock = require('nock')
const path = require('path')
const testHelper = require('../_helper')

const lab = exports.lab = Lab.script()
const expect = Code.expect

lab.experiment('jenkins-playground script', () => {
  const configXml = path.resolve(__dirname, '../fixtures/config.xml')
  var room
  var helper
  var scope

  lab.before((done) => {
    process.env.HUBOT_JENKINS_URL = 'http://jenkins.url'
    helper = new Helper('../../scripts/jenkins-playground.coffee')

    done()
  })

  lab.beforeEach((done) => {
    room = helper.createRoom()
    scope = nock(process.env.HUBOT_JENKINS_URL)

    done()
  })

  lab.afterEach((done) => {
    room.destroy()

    done()
  })

  lab.test('error getting config', (done) => {
    scope.get('/job/repo-playground/config.xml').replyWithError('testing')

    testHelper.waitForReply(room, 'hubot put feature on playground for repo', scope)
    .then(() => {
      expect(room.messages[1][1]).to.startWith('[jenkins][repo] error getting config')

      done()
    })
    .catch(done)
  })

  lab.test('error getting branch name', (done) => {
    scope.get('/job/repo-playground/config.xml').reply(200, '')

    testHelper.waitForReply(room, 'hubot put feature on playground for repo', scope)
    .then(() => {
      expect(room.messages).to.have.length(2)
      expect(room.messages[1][1]).to.startWith('[jenkins][repo] error getting branch name')

      done()
    })
  })

  lab.test('error posting new config', (done) => {
    const url = '/job/repo-playground/config.xml'
    scope
      .get(url).replyWithFile(200, configXml)
      .filteringRequestBody(function (body) {
        return '*'
      }).post(url, '*').replyWithError('fooey')

    testHelper.waitForReply(room, 'hubot put alpha on playground for repo', scope)
    .then(() => {
      expect(room.messages[1][1]).to.startWith('[jenkins][repo] error posting new config')

      done()
    })
    .catch(done)
  })

  lab.test('error triggering new build', (done) => {
    const url = '/job/repo-playground/'
    const msg = 'grapefruit'
    scope
      .get(url + 'config.xml').replyWithFile(200, configXml)
      .filteringRequestBody(function (body) {
        return '*'
      }).post(url + 'config.xml', '*').reply(200)
      .post(url + 'build', '*').replyWithError(msg)

    testHelper.waitForReply(room, 'hubot put beta on playground for repo', scope)
    .then(() => {
      expect(room.messages[1][1]).to.equal('[jenkins][repo] error triggering new build: ' + msg)

      done()
    })
    .catch(done)
  })

  lab.test('error unexpected response', (done) => {
    const url = '/job/repo-playground/'
    scope
      .get(url + 'config.xml').replyWithFile(200, configXml)
      .filteringRequestBody(function (body) {
        return '*'
      }).post(url + 'config.xml', '*').reply(200)
      .post(url + 'build', '*').reply(403)

    testHelper.waitForReply(room, 'hubot put gamma on playground for repo', scope)
    .then(() => {
      expect(room.messages[1][1]).to.equal('[jenkins][repo] error unexpected response: 403')

      done()
    })
    .catch(done)
  })

  lab.test('updateConfig works', (done) => {
    const url = '/job/repo-playground/'
    scope
      .get(url + 'config.xml').replyWithFile(200, configXml)
      .filteringRequestBody(function (body) {
        return '*'
      }).post(url + 'config.xml', '*').reply(200)
      .post(url + 'build', '*').reply(201)

    testHelper.waitForReply(room, 'hubot put gamma on playground for repo', scope)
    .then(() => {
      expect(room.messages[1][1]).to.equal('[jenkins][repo] branch configured and queued to build!')

      done()
    })
    .catch(done)
  })

  lab.test('clean up error', (done) => {
    const msg = 'watermelon'
    scope.get('/api/json').replyWithError(msg)

    testHelper.waitForReply(room, 'hubot clean up playground', scope)
    .then(() => {
      expect(room.messages).to.have.length(2)
      expect(room.messages[1][1]).to.equal('Error getting jobs: ' + msg)

      done()
    })
  })

  lab.test('clean up', (done) => {
    scope
      .get('/api/json').reply(200, JSON.stringify({
        jobs: [
          {
            url: process.env.HUBOT_JENKINS_URL + '/job/repo-a-playground/',
            name: 'repo-a-playground'
          },
          {
            url: process.env.HUBOT_JENKINS_URL + '/job/repo-b-playground/',
            name: 'repo-b-playground'
          }
        ]
      }))

    testHelper.waitForReply(room, 'hubot clean up playground', scope)
    .then(() => {
      expect(room.messages[1][1]).to.startWith('[jenkins][repo-a-playground]')
      expect(room.messages[2][1]).to.startWith('[jenkins][repo-b-playground]')
      expect(room.messages[3][1]).to.contain('All done!')

      done()
    })
    .catch(done)
  })
})
