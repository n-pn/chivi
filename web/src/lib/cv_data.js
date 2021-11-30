const escape_tags = { '&': '&amp;', '"': '&quot;', "'": '&apos;' }

function escape_html(str) {
  return str && str.replace(/[&<>]/g, (x) => escape_tags[x] || x)
}

export default class CvData {
  static parse_lines(input = '') {
    return input.split('\n').map((x) => new CvData(x))
  }

  constructor(input) {
    this.data = this.parse(Array.from(input), 0)[0]
  }

  parse(chars, i = 0) {
    const data = []
    let term = []
    let word = ''

    while (i < chars.length) {
      const char = chars[i]
      i += 1

      switch (char) {
        case '〉':
          if (word) term.push(word)
          if (term.length > 0) data.push(term)
          return [data, i]

        case '〈':
          if (word) term.push(word)
          if (term.length > 0) data.push(term)
          const fold = chars[i]
          const [child, j] = this.parse(chars, i + 1)
          data.push([child, fold])
          i = j

          word = ''
          term = []

          break

        case '\t':
          if (word) term.push(word)
          if (term.length > 0) data.push(term)

          word = ''
          term = []

          break

        case 'ǀ':
          term.push(word)
          word = ''
          break

        default:
          word += char
      }
    }

    if (word) term.push(word)
    if (term.length > 0) data.push(term)

    return [data, i]
  }

  render_hv() {
    let res = ''

    for (const [val, dic, idx] of this.data) {
      if (val == ' ') {
        res += ' '
        continue
      }

      let chars = val.split(' ')

      res += `<c-g data-d=${dic}>`
      for (let j = 0; j < chars.length; j++) {
        if (j > 0) res += ' '

        const v = escape_html(chars[j])
        const l = +idx + j
        const u = l + 1
        res += `<v-n data-d=2 data-l=${l} data-u=${u}>${v}</v-n>`
      }
      res += '</c-g>'
    }

    return res
  }

  get html() {
    this._html = this._html || this.render_cv(this.data, false)
    return this._html
  }

  get text() {
    this._text = this._text || this.render_cv(this.data, true)
    return this._text
  }

  render_cv(data = this.data, text = true) {
    let res = ''
    let lvl = 0

    for (const [val, dic, idx, len] of data) {
      if (Array.isArray(val)) {
        const inner = this.render_cv(val, text)

        if (text) res += inner
        else res += `<v-g data-d=${dic}>${inner}</v-g>`
        continue
      }

      if (val == ' ') {
        res += ' '
        continue
      }

      const fval = val[0]
      if (fval == '“' || fval == '‘') {
        lvl += 1
        res += '<em>'
      } else if (fval == '⟨') {
        res += '<cite>'
      }

      const esc = escape_html(val)

      if (text) res += esc
      else {
        const l = idx
        const u = +idx + +len
        res += `<v-n data-d=${dic} data-l=${l} data-u=${u}>${esc}</v-n>`
      }

      const lval = val[val.length - 1]

      if (lval == '”' || lval == '’') {
        lvl -= 1
        res += '</em>'
      } else if (fval == '⟩') {
        res += '</cite>'
      }
    }

    while (lvl < 0) {
      res = '<em>' + res
      lvl++
    }

    while (lvl > 0) {
      res = res + '</em>'
      lvl--
    }

    return res
  }

  static render_zh(input) {
    let res = ''
    let idx = 0

    for (const key of Array.from(input)) {
      res += `<c-g data-d=1>`

      for (const k of Array.from(key)) {
        res += `<v-n data-d=2 data-i=${idx} data-l=1>${escape_html(k)}</v-n>`
        idx += 1
      }

      res += '</c-g>'
    }

    return res
  }
}
