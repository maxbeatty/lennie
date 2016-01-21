module.exports = {
  waitForReply: function (room, command, scope) {
    return new Promise((resolve, reject) => {
      room.user
        .say('alice', command)
        .then(() => {
          const nid = setInterval(() => {
            if (scope.isDone() && room.messages.length > 1) {
              clearInterval(nid)
              resolve()
            }
          }, 10)
        })
    })
  }
}
