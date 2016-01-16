const Code = require('code')
const Lab = require('lab')
const Helper = require('hubot-test-helper')
const nock = require('nock')
const testHelper = require('../_helper')

const lab = exports.lab = Lab.script()
const expect = Code.expect

lab.experiment('jenkins-deploy script', () => {
  var room
  var helper
  var scope

  lab.before((done) => {
    process.env.HUBOT_JENKINS_URL = 'http://jenkins.url'
    helper = new Helper('../../scripts/jenkins-deploy.coffee')

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

  lab.test('error getting jobs', (done) => {
    testHelper.waitForReply(room, 'hubot turn off deploys', scope)
    .then(() => {
      expect(room.messages).to.have.length(2)
      expect(room.messages[1][1]).to.startWith('Error getting jobs')

      done()
    })
    .catch(done)
  })

  lab.test('error toggling', (done) => {
    testHelper.waitForReply(room, 'hubot turn on deploys for repo', scope)
    .then(() => {
      expect(room.messages).to.have.length(2)
      expect(room.messages[1][1]).to.startWith('Error trying to enable')

      done()
    })
    .catch(done)
  })

  lab.test('toggle individual', (done) => {
    scope.post('/job/repo-deploy/enable', '').reply(302, '')

    testHelper.waitForReply(room, 'hubot turn on deploys for repo', scope)
    .then(() => {
      expect(room.messages).to.have.length(2)
      expect(room.messages[1][1]).to.startWith('Turned on 1 deploy jobs')

      done()
    })
    .catch(done)
  })

  lab.test('error toggling individual', (done) => {
    scope.post('/job/repo-deploy/enable', '').reply(500, '')

    testHelper.waitForReply(room, 'hubot turn on deploys for repo', scope)
    .then(() => {
      expect(room.messages).to.have.length(2)
      expect(room.messages[1][1]).to.startWith('Turned on 0 deploy jobs')

      done()
    })
    .catch(done)
  })

  lab.test('toggle all jobs', (done) => {
    scope
      .get('/api/json').reply(200, JSON.stringify({jobs: [
        {url: '/job/repo-a-deploy/', name: 'repo-a-deploy'},
        {url: '/job/repo-b-deploy/', name: 'repo-b-deploy'}
      ]}))
      .post('/job/repo-a-deploy/disable', '').reply(302, '')
      .post('/job/repo-b-deploy/disable', '').reply(302, '')

    testHelper.waitForReply(room, 'hubot turn off deploys', scope)
    .then(() => {
      expect(room.messages).to.have.length(2)
      expect(room.messages[1][1]).to.startWith('Turned off 2 deploy jobs')

      done()
    })
  })
})
