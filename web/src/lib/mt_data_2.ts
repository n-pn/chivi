const escape_tags = { '&': '&amp;', '"': '&quot;', "'": '&apos;' }

function escape_html(str: string | null) {
  return str && str.replace(/[&<>]/g, (x) => escape_tags[x] || x)
}

export default class MtData2 {
  data: any[]
  _html: string
  _text: string

  static parse_lines(input = ''): MtData2[] {
    if (!input) return []

    return input
      .trim()
      .split('\n')
      .map((x) => new MtData2(x))
  }

  constructor(input: string) {
    this.data = this.parse(Array.from(input), 0)[0]
  }

  parse(chars: string[], i = 0): any[] {
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

  get html() {
    this._html = this._html || this.render_cv(this.data, false)
    return this._html
  }

  get text() {
    this._text = this._text || this.render_cv(this.data, true)
    return this._text
  }

  render_cv(data = this.data, text = true, lvl = 0) {
    let res = ''

    for (const [val, dic, idx, len] of data) {
      if (Array.isArray(val)) {
        const inner = this.render_cv(val, text, lvl)

        if (text) res += inner
        else res += `<v-g data-d=${dic}>${inner}</v-g>`
        continue
      }

      if (val == ' ') {
        res += ' '
        continue
      }

      const esc = escape_html(val)

      if (text) res += esc
      else {
        const l = idx
        const u = +idx + +len
        res += `<v-n data-d=${dic} data-l=${l} data-u=${u}>${esc}</v-n>`
      }
    }

    const first_val = data[0][0]

    if (typeof first_val == 'string') {
      const fval = first_val[0]

      if (fval == '“' || fval == '‘') {
        return '<em>' + res + '</em>'
      } else if (fval == '⟨') {
        return '<cite>' + res + '</cite>'
      }
    }

    const last_val = data[data.length - 1][0]
    if (typeof last_val == 'string') {
      const lval = last_val[last_val.length - 1]

      if (lval == '”' || lval == '’') {
        lvl -= 1
        res += '</em>'
      } else if (lval == '⟩') {
        res += '</cite>'
      }
    }

    return res
  }

  render_hv() {
    let res = ''

    for (const [val, dic, idx, len] of this.data) {
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
        res += `<x-n data-d=2 data-l=${l} data-u=${u}>${v}</x-n>`
      }
      res += '</c-g>'
    }

    return res
  }

  static render_zh(input: string) {
    let res = ''
    let idx = 0

    for (const chars of Array.from(input)) {
      res += `<c-g data-d=1>`

      for (let j = 0; j < chars.length; j++) {
        const v = escape_html(chars[j])
        const u = idx + 1
        res += `<x-n data-d=2 data-l=${idx} data-u=${u}>${v}</x-n>`
        idx += 1
      }

      res += '</c-g>'
    }

    return res
  }
}
