import { fnv_1a_32 } from '$utils/hash_util'

const CHAR_LIMIT = 2048
const CHAR_UPPER = 3200

function char_limit(char_count: number) {
  if (char_count < CHAR_UPPER) return CHAR_UPPER
  return (char_count / (char_count / CHAR_LIMIT)) | 0
}

export function split_parts(lines: string[]) {
  const [title, ...paras] = lines

  const psize = paras.reduce((a, l) => a + l.length + 1, 0)
  const limit = char_limit(psize)

  const parts = []

  let cpart = title
  let count = 0

  for (const line of paras) {
    if (count > 0) cpart += '\n'
    cpart += line

    count += line.length
    if (count < limit) continue

    parts.push(cpart)
    cpart = title
    count = 0
  }

  if (count > 0) parts.push(cpart)
  return parts
}
export class Czdata {
  ch_no: number
  chdiv: string

  lines: string[]
  title: string

  parts: string[]

  constructor(ch_no: number, chdiv = '', lines = []) {
    this.ch_no = ch_no
    this.chdiv = chdiv
    this.lines = lines
    this.title = lines[0]
    this.parts = split_parts(lines)
  }

  get size() {
    return this.lines.reduce((memo, line) => memo + line.length + 1, 0)
  }

  toJSON() {
    return {
      ch_no: this.ch_no,
      chdiv: this.chdiv,
      title: this.title,
      ztext: this.lines.join('\n'),
    }
  }
}

function scrub_text(text: string): string {
  const to_full = (c: string) => String.fromCharCode(c.charCodeAt(0) + 0xfee0)
  return text.replace(/\t/g, '  ').replace(/[!-~]/g, to_full).trim()
}

export class Cztext {
  lines: string[]
  start: number
  chdiv: string

  constructor(input: string, start = 1, chdiv = '') {
    this.lines = input.split('\n')
    this.start = start
    this.chdiv = chdiv
  }

  // split text by adding `///` before each chapter
  split_slash(repeat = 3) {
    if (repeat < 2) repeat = 2

    const input = this.lines.filter(Boolean)
    const chaps: Czdata[] = []

    let chdiv = this.chdiv
    let cbody: string[] = []

    const regex = new RegExp(`^\/{${repeat},}(.*?)$`, 'u')
    let found: RegExpMatchArray | null

    for (const line of input) {
      found = line.match(regex)

      if (found) {
        if (cbody.length > 0) this.append(chaps, cbody, chdiv)
        chdiv = scrub_text(found[1]) || chdiv
        cbody = []
      } else {
        cbody.push(scrub_text(line))
      }
    }

    if (cbody.length > 0) this.append(chaps, cbody, chdiv)
    return chaps
  }

  // split text by blank lines
  split_blank(min_blanks = 2) {
    if (min_blanks < 1) min_blanks = 1
    let blank_count = min_blanks

    const is_title_fn = (line: string) => {
      if (line !== '') {
        const is_title = blank_count >= min_blanks
        blank_count = 0
        return is_title
      } else {
        blank_count += 1
        return false
      }
    }

    return this.do_split(is_title_fn)
  }

  // split text if chapter body is nested
  split_block(blank_before = false) {
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

    return this.do_split(is_title_fn)
  }

  // split text by chapter most popular title formats
  split_label(labels: string) {
    const hanzi = '零〇一二两三四五六七八九十百千'
    const regex = new RegExp(`^[ 　]*第[\\d${hanzi}]+[${labels}]`)

    const is_title_fn = (line: string) => regex.test(line)
    return this.do_split(is_title_fn)
  }

  // split text by custom regular expression
  split_regex(re_str: string) {
    const regex = new RegExp(re_str)
    const is_title_fn = (line: string) => regex.test(line)
    return this.do_split(is_title_fn)
  }

  do_split(is_title_fn: (line: string) => boolean) {
    const chaps: Czdata[] = []

    let chdiv = this.chdiv
    let cbody: string[] = []
    let prev_was_chdiv = false

    for (let line_no = 0; line_no < this.lines.length; line_no++) {
      const line = this.lines[line_no]
      const is_title = is_title_fn(line)

      const line_trim = scrub_text(line)
      if (!line_trim) continue

      if (!is_title) {
        cbody.push(line)
      } else if (cbody.length > 1) {
        this.append(chaps, cbody, chdiv)
        cbody = [line_trim]
        prev_was_chdiv = false
      } else if (prev_was_chdiv) {
        throw `Lỗi dòng #${line_no + 1} (${line}): Chương trước thiếu nội dung!`
      } else if (!cbody[0]) {
        cbody.push(line_trim)
        prev_was_chdiv = false
      } else {
        chdiv = cbody[0]
        cbody[0] = line_trim
        prev_was_chdiv = true
      }
    }

    if (cbody[0]) this.append(chaps, cbody, chdiv)

    return chaps
  }

  append(chaps: Czdata[], cbody: string[], chdiv = this.chdiv) {
    chaps.push(new Czdata(chaps.length + this.start, chdiv, cbody))
  }
}
