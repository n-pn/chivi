import fast_diff from 'fast-diff'

export function hash_str(s: string) {
  var hash = 0

  for (let i = 0; i < s.length; i++) {
    const chr = s.charCodeAt(i)
    hash = (hash << 5) - hash + chr
    hash |= 0
  }

  if (hash < 0) hash = -hash
  return hash.toString(32)
}

const valid_re = /^[\s　]*第|[。！」#＊”\p{Pe}\p{Pf}]\s*$/

export function fix_breaks(input: string, min_invalid = 15) {
  const lines = input.split(/\r\n?|\n/)
  let output = ''
  let was_invalid = false

  for (let line of lines) {
    line = line.replace(/^[\s　]*/, '')

    if (!line) continue
    else output += line

    if (was_invalid || line.length > min_invalid) {
      was_invalid = !valid_re.test(line)
    } else {
      was_invalid = false
    }

    if (!was_invalid) output += '\n'
  }

  return output
}

export async function opencc(input: string, config = 'hk2s') {
  const href = '/_sp/opencc?config=' + config
  const init = { method: 'POST', body: input }
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

export async function translate(
  input: string,
  dname: string = 'combine',
  fetch = globalThis.fetch
) {
  const href = `/_db/qtran?dname=${dname}&_simp=true`
  const body = JSON.stringify({ input })
  const headers = { 'Content-Type': 'application/json' }

  const res = await fetch(href, { method: 'POST', headers, body })
  return await res.text()
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
