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

export function render_zh(data) {
  let res = ''
  let idx = 0

  for (const key of Array.from(data)) {
    res += `<c-z data-d=1>`

    for (const k of Array.from(key)) {
      res += `<c-v data-d=2 data-i=${idx} data-l=1>${escape_html(k)}</c-v>`
      idx += 1
    }

    res += '</c-z>'
  }

  return res
}

export function split_mtdata(input = '', skip = 2) {
  const lines = input.split('\n')
  const output = []

  for (let i = 0; i < lines.length; i += skip) {
    output.push(new MtData(lines[i], lines[i + 1]))
  }

  return output
}

export class MtData {
  constructor(data, orig = '') {
    this.data = data.split('\t').map((x) => x.split('ǀ'))

    this.orig = orig
  }

  get text() {
    this._text = this._text || this.render(true)
    return this._text
  }

  get html() {
    this._html = this._html || this.render(false)
    return this._html
  }

  render(plain = true) {
    let res = ''
    let lvl = 0

    for (const [val, dic, idx, len] of this.data) {
      if (val == ' ') {
        res += ' '
        continue
      }

      const fval = val[0]
      if (fval == '“' || fval == '‘') {
        lvl += 1
        res += '<em>'
      }

      const esc = escape_html(val)

      if (plain) res += esc
      else res += `<c-v data-d=${dic} data-i=${idx} data-l=${len}>${esc}</c-v>`

      const lval = val[val.length - 1]

      if (lval == '”' || lval == '’') {
        lvl -= 1
        res += '</em>'
      }
    }

    if (lvl < 0) return '<em>' + res
    if (lvl > 0) return res + '</em>'
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
