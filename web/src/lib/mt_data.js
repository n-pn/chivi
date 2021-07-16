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
    this._text = this._text || this.render('text')
    return this._text
  }

  get html() {
    this._html = this._html || this.render('html')
    return this._html
  }

  render(mode = 'text') {
    let res = ''
    let lvl = 0
    let i = 0
    let p = 0

    for (const [key, val, tag, dic] of this.data) {
      if (tag == 'wyz') {
        lvl += 1
        res += '<em>'
      }

      if (mode == 'html') {
        const k = escape_html(key)
        const v = escape_html(val)
        res += `<c-v data-k="${k}" data-t="${tag}" data-d=${dic} data-i=${i} data-p=${p}>${v}</c-v>`
      } else {
        res += escape_html(val)
      }

      if (tag == 'wyy') {
        lvl -= 1
        res += '</em>'
      }

      i += 1
      p += key.length
    }

    if (lvl < 0) {
      res = '<em>' + res
    } else if (lvl > 0) {
      res += '</em>'
    }

    return res
  }

  substr(idx, min = 4, max = 10) {
    let input = ''

    for (let j = idx - 1; j >= 0; j--) {
      const [key] = this.data[j]
      input = key + input
      if (input.length >= min) break
    }

    const lower = input.length
    input += this.data[idx][0]
    const upper = input.length

    let limit = upper + min
    if (limit < max) limit = max

    for (let j = idx + 1; j < this.data.length; j++) {
      const [key] = this.data[j]
      input = input + key
      if (input.length > limit) break
    }

    return [input, lower, upper > lower ? upper : lower + 1]
  }

  render_zh() {
    let res = ''
    let i = 0
    let p = 0

    for (const [key, _, tag, dic] of this.data) {
      const k = escape_html(key)
      res += `<c-v data-k=${k} data-t="${tag}" data-i=${i} data-d=${dic}>`

      for (const kk of Array.from(key)) {
        const ke = escape_html(kk)
        res += `<x-v data-k=${ke} data-p=${p}>${ke}</x-v>`
        p += 1
      }

      res += '</c-v>'

      i += 1
    }

    return res
  }

  render_hv() {
    let res = ''
    let i = 0
    let p = 0

    for (const [key, val, _tag, dic] of this.data) {
      let key_chars = key.split('')
      let val_chars = val.split(' ')

      if (key_chars.length != val_chars.length) {
        res += val
        i += 1
        p += key_chars.length
        continue
      }

      res += `<c-v data-k=${escape_html(key)} data-i=${i} data-d=${dic}>`
      for (let j = 0; j < key_chars.length; j++) {
        const k = escape_html(key_chars[j])
        const v = escape_html(val_chars[j])
        if (j > 0) res += ' '
        res += `<x-v data-k=${k} data-i=${i} data-p=${p} data-d=${dic}>${v}</x-v>`
        p += 1
      }
      res += '</c-v>'

      i += 1
    }

    return res
  }
}
