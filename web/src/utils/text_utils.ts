import fast_diff from 'fast-diff'

export function hash_str(str: string) {
  var hash = 0

  for (let i = 0; i < str.length; i++) {
    const chr = str.charCodeAt(i)
    hash = (hash << 5) - hash + chr
    hash |= 0
  }

  if (hash < 0) hash = -hash
  return hash.toString(32)
}

export function fix_breaks(input: string, min_invalid = 15) {
  const lines = input.split(/\r\n?|\n/)

  let output = ''

  for (let line of lines) {
    line = line.trim()
    if (!line) continue

    output += line
    if (is_full_line(line, min_invalid)) output += '\n'
  }

  return output
}

export function trim_spaces(input: string) {
  const lines = input.split(/\r\n?|\n/)
  return lines.filter(Boolean).join('\n')
}

const full_line_re_1 = /^[\s 　]*第/
const full_line_re_2 = /[。？！”」#＊）】…\.\p{Pe}\p{Pf}]\s*$/u

const is_full_line = (line: string, min_invalid = 15) => {
  if (line.length < min_invalid) return true
  return full_line_re_1.test(line) || full_line_re_2.test(line)
}

export async function opencc(body: string, config = 'hk2s') {
  const href = `/_sp/opencc?config=${config}`
  const init = { headers: text_headers, method: 'POST', body }
  return await fetch(href, init).then((r) => r.text())
}

export function diff_html(orig: string, edit: string, show_deleted = false) {
  let html = ''

  for (const [type, text] of fast_diff(orig, edit)) {
    if (type == 0) html += text
    else if (type == 1) html += `<ins>${text}</ins>`
    else if (show_deleted && text != '\n') html += `<del>${text}</del>`
  }

  return html
}

const text_headers = { 'Content-Type': 'text_plain' }

export async function translate(
  input: string,
  wn_id: number = 0,
  fetch = globalThis.fetch
) {
  if (!input) return ''
  const href = `/_m1/qtran?wn_id=${wn_id}&format=txt`
  const init = { method: 'POST', headers: text_headers, body: input }
  return await fetch(href, init).then((r) => r.text())
}

export function unaccent(input: string) {
  return input
    .normalize('NFD')
    .toLowerCase()
    .replace(/[\u0300-\u036f]/g, '')
    .replace('đ', 'd')
}

export function slugify(input: string) {
  input = unaccent(input)
  return input.split(/\W+/).filter(Boolean).join('-')
}
