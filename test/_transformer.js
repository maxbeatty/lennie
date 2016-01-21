const Coffee = require('coffee-script')
const Btoa = require('btoa')

module.exports = [
  {
    ext: '.coffee',
    transform: function (content, filename) {
      // Make sure to only transform your code or the dependencies you want
      if (filename.indexOf('node_modules') === -1 || filename.indexOf('hubot') > -1) {
        const result = Coffee.compile(content, {
          sourceMap: true,
          inline: true,
          sourceRoot: '/',
          sourceFiles: [filename]
        })

        return result.js +
          '\n//# sourceMappingURL=data:application/json;base64,' +
          Btoa(unescape(encodeURIComponent(result.v3SourceMap)))
      }

      return content
    }
  }
]
