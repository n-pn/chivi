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
    this._text = this._text || this.render()
    return this._text
  }

  get html() {
    this._html = this._html || this.render(true)
    return this._html
  }

  render(html = false) {
    let res = ''
    let lvl = 0
    let i = 0
    let p = 0

    for (const [key, val, tag, dic] of this.data) {
      if (tag == 'wyz') {
        lvl += 1
        res += '<em>'
      }

      if (html) {
        const k = escape_html(key)
        const v = escape_html(val)
        res += `<x-v data-k="${k}" data-t="${tag}" data-d=${dic} data-i=${i} data-p=${p}>${v}</x-v>`
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
}
