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

export function split_mtdata(input = '') {
  const lines = input.split('\n').map((x) => x.trim())
  return lines.filter((x) => x).map((line) => new MtData(line))
}

export class MtData {
  constructor(input) {
    if (Array.isArray(input)) {
      this.data = input
      return
    }

    this.data = input.split('\t').map((x) => {
      const [key, val, tag, dic] = x.split('ǀ')
      return [key, val || '', tag || '', +dic]
    })
  }

  get orig() {
    this._orig = this._orig || this.data.map((x) => x[0]).join('')
    return this._orig
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
    let idx = 0

    for (const [key, val, tag, dic] of this.data) {
      if (tag == 'wyz') {
        lvl += 1
        res += '<em>'
      }

      const esc = escape_html(val)
      const len = key.length

      if (plain) res += esc
      else res += `<c-v data-d=${dic} data-i=${idx} data-l=${len}>${esc}</c-v>`
      idx += len

      if (tag == 'wyy') {
        lvl -= 1
        res += '</em>'
      }
    }

    if (lvl < 0) {
      res = '<em>' + res
    } else if (lvl > 0) {
      res += '</em>'
    }

    return res
  }

  render_hv() {
    let res = ''
    let idx = 0

    for (const [key, val, _tag, dic] of this.data) {
      let key_chars = key.split('')
      let val_chars = val.split(' ')

      if (key_chars.length != val_chars.length) {
        res += val
        idx += key_chars.length
        continue
      }

      res += `<c-z data-d=${dic}>`
      for (let j = 0; j < key_chars.length; j++) {
        if (j > 0) res += ' '
        const val = escape_html(val_chars[j])
        res += `<c-v data-d=2 data-i=${idx} data-l="1">${val}</c-v>`
        idx += 1
      }
      res += '</c-z>'
    }

    return res
  }
}
