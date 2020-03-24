const path = require('path')
const sass = require('node-sass')

module.exports = {
  preprocess: {
    style: async ({ content, attributes, filename }) => {
      if (content.length === 0) return { code: content }

      const { type, lang } = attributes
      if (type !== 'text/scss' && lang !== 'scss') return

      const prepend_content = '@import "~mould/css/essence";\n'
      content = prepend_content + content

      const options = {
        data: content,
        sourceMap: true,
        includePaths: [
          path.dirname(filename),
          path.resolve(__dirname, 'src/styles'),
          path.resolve(__dirname, 'node_modules'),
        ],
        outFile: filename + '.css',
      }

      return new Promise((resolve, reject) => {
        sass.render(options, (err, result) => {
          if (err) return reject(err)
          resolve({
            code: result.css.toString(),
            map: result.map.toString(),
          })
        })
      })
    },
  },
}
