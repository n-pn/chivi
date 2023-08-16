export interface Zchap {
  ch_no: number
  title: string
  chdiv: string
  ztext: string
}

function add_to_list(chaps: Zchap[], lines: string[], chdiv = '', start = 1) {
  const ch_no = chaps.length + start
  chaps.push({ ch_no, chdiv, title: lines[0], ztext: lines.join('\n') })
}

function scrub_text(text: string): string {
  const to_full = (c: string) => String.fromCharCode(c.charCodeAt(0) + 0xfee0)
  return text.replace(/\t/g, '  ').replace(/[!-~]/g, to_full).trim()
}

function split_text(
  input: string,
  chdiv = '',
  start = 1,
  is_title_fn: (line: string) => boolean
) {
  const lines = input.split('\n')
  const chaps: Zchap[] = []

  let prev_was_chdiv = false
  let pending: string[] = []

  for (let line_no = 0; line_no < lines.length; line_no++) {
    const line = lines[line_no]
    const is_title = is_title_fn(line)

    const clean_line = scrub_text(line)
    if (!clean_line) continue

    if (!is_title) {
      pending.push(line)
    } else if (pending.length > 1) {
      add_to_list(chaps, pending, chdiv, start)
      pending = [clean_line]
      prev_was_chdiv = false
    } else if (prev_was_chdiv) {
      throw `Lỗi dòng #${line_no + 1} (${line}): Chương trước thiếu nội dung!`
    } else if (!pending[0]) {
      pending.push(clean_line)
      prev_was_chdiv = false
    } else {
      chdiv = pending[0]
      pending[0] = clean_line
      prev_was_chdiv = true
    }
  }

  if (pending[0]) add_to_list(chaps, pending, chdiv, start)

  return chaps
}

export function split_mode_0(input: string, repeat = 3, chdiv = '', start = 0) {
  if (repeat < 1) repeat = 1
  const zlines = input.split('\n').filter(Boolean)
  const chlist: Zchap[] = []

  let pending: string[] = []

  const regex = new RegExp(`^\/{${repeat},}(.*?)$`, 'u')
  let found: RegExpMatchArray | null

  for (const line of zlines) {
    found = line.match(regex)

    if (found) {
      if (pending.length > 0) add_to_list(chlist, pending, chdiv, start)
      chdiv = scrub_text(found[1]) || chdiv
      pending = []
    } else {
      pending.push(scrub_text(line))
    }
  }

  if (pending.length > 0) add_to_list(chlist, pending, chdiv, start)

  return chlist
}

export function split_mode_1(
  input: string,
  min_blanks = 2,
  trim = false,
  chdiv = '',
  start = 1
) {
  if (min_blanks < 1) min_blanks = 1
  let blank_count = min_blanks

  const is_title_fn = (line: string) => {
    if (trim) line = scrub_text(line)

    if (line !== '') {
      const is_title = blank_count >= min_blanks
      blank_count = 0
      return is_title
    } else {
      blank_count += 1
      return false
    }
  }

  return split_text(input, chdiv, start, is_title_fn)
}

export function split_mode_2(
  input: string,
  blank_before = false,
  chdiv = '',
  start = 1
) {
  let prev_was_blank = true

  const is_title_fn = (line: string) => {
    if (line.match(/^[\t\s　]/)) {
      prev_was_blank = !line.trim()
      return false
    } else {
      const is_title = prev_was_blank || !blank_before
      prev_was_blank = false
      return is_title
    }
  }

  return split_text(input, chdiv, start, is_title_fn)
}

const hannum = '零〇一二两三四五六七八九十百千'
export function split_mode_3(
  input: string,
  labels: string,
  chdiv = '',
  start = 1
) {
  const regex = new RegExp(`^[ 　]*第[\\d${hannum}]+[${labels}]`)
  const is_title_fn = (line: string) => regex.test(line)
  return split_text(input, chdiv, start, is_title_fn)
}

export function split_mode_4(
  input: string,
  re_str: string,
  chdiv = '',
  start = 1
) {
  const regex = new RegExp(re_str)
  const is_title_fn = (line: string) => regex.test(line)
  return split_text(input, chdiv, start, is_title_fn)
}
