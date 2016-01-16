const Code = require('code')
const Lab = require('lab')
const Helper = require('hubot-test-helper')
const nock = require('nock')

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
    room.user.say('alice', 'hubot turn off deploys').then(() => {
      setTimeout(() => {
        expect(room.messages).to.have.length(2)
        expect(room.messages[1][1]).to.startWith('Error getting jobs')

        done()
      }, 10)
    }).catch(done)
  })

  lab.test('error toggling', (done) => {
    room.user.say('alice', 'hubot turn on deploys for repo').then(() => {
      setTimeout(() => {
        expect(room.messages).to.have.length(2)
        expect(room.messages[1][1]).to.startWith('Error trying to enable')

        done()
      }, 10)
    }).catch(done)
  })

  lab.test('toggle individual', (done) => {
    scope.post('/job/repo-deploy/enable', '').reply(302, '')

    room.user.say('alice', 'hubot turn on deploys for repo').then(() => {
      setTimeout(() => {
        expect(room.messages).to.have.length(2)
        expect(room.messages[1][1]).to.startWith('Turned on 1 deploy jobs')

        done()
      }, 10)
    }).catch(done)
  })

  lab.test('error toggling individual', (done) => {
    scope.post('/job/repo-deploy/enable', '').reply(500, '')

    room.user.say('alice', 'hubot turn on deploys for repo').then(() => {
      setTimeout(() => {
        expect(room.messages).to.have.length(2)
        expect(room.messages[1][1]).to.startWith('Turned on 0 deploy jobs')

        done()
      }, 10)
    }).catch(done)
  })

  lab.test('toggle all jobs', (done) => {
    scope
      .get('/api/json').reply(200, JSON.stringify({jobs: [
        {url: '/job/repo-a-deploy/', name: 'repo-a-deploy'},
        {url: '/job/repo-b-deploy/', name: 'repo-b-deploy'}
      ]}))
      .post('/job/repo-a-deploy/disable', '').reply(302, '')
      .post('/job/repo-b-deploy/disable', '').reply(302, '')

    room.user.say('alice', 'hubot turn off deploys').then(() => {
      setTimeout(() => {
        expect(room.messages).to.have.length(2)
        expect(room.messages[1][1]).to.startWith('Turned off 2 deploy jobs')

        done()
      }, 10)
    })
  })
})
