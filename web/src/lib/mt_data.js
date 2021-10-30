const escape_tags = {
  '<': '&lt;',
  '>': '&gt;',
  '"': '&quot;',
  "'": '&apos;',
}

function replace_tag(tag) {
  return escape_tags[tag] || tag
}

function escape_html(str) {
  if (!str) return ''
  return str.replace(/[&<>]/g, replace_tag)
}

export class MtData {
  static render_zh(input) {
    let res = ''
    let idx = 0

    for (const key of Array.from(input)) {
      res += `<c-z data-d=1>`

      for (const k of Array.from(key)) {
        res += `<c-v data-d=2 data-i=${idx} data-l=1>${escape_html(k)}</c-v>`
        idx += 1
      }

      res += '</c-z>'
    }

    return res
  }

  static parse_lines(input = '') {
    const lines = input.split('\n')
    const output = []

    for (let i = 0; i < lines.length; i++) {
      output.push(new MtData(lines[i]))
    }

    return output
  }

  constructor(input) {
    const chars = Array.from(input)
    this.data = this.parse(chars, 0)[0]
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

  get text() {
    this._text = this._text || this.render(this.data, true)
    return this._text
  }

  get html() {
    this._html = this._html || this.render(this.data, false)
    return this._html
  }

  render(data, plain = true) {
    let res = ''
    let lvl = 0

    for (const [val, dic, idx, len] of data) {
      if (Array.isArray(val)) {
        const inner = this.render(val, plain)

        if (plain) res += inner
        else res += `<c-g data-d=${dic}>${inner}</c-g>`
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

      if (plain) res += esc
      else res += `<c-v data-d=${dic} data-i=${idx} data-l=${len}>${esc}</c-v>`

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

  render_hv() {
    let res = ''

    for (const [val, dic, idx] of this.data) {
      if (val == ' ') {
        res += ' '
        continue
      }

      let chars = val.split(' ')

      res += `<c-z data-d=${dic}>`
      for (let j = 0; j < chars.length; j++) {
        if (j > 0) res += ' '
        const val = escape_html(chars[j])
        res += `<c-v data-d=2 data-i=${+idx + j} data-l="1">${val}</c-v>`
      }
      res += '</c-z>'
    }

    return res
  }
}
