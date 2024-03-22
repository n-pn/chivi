import { fnv_1a_32 } from '$utils/hash_util'

const CHAR_LIMIT = 2048

function calc_char_limit(lines: string[], char_limit: number) {
  const char_upper = char_limit * 1.5
  const char_count = lines.reduce((a, l) => a + l.length + 1, 0)

  if (char_count <= char_upper) return char_upper
  return Math.floor(char_count / Math.round(char_count / char_limit))
}

export function split_parts(lines: string[], max_chars = CHAR_LIMIT) {
  const limit = calc_char_limit(lines, max_chars)
  const parts = [] as string[]

  let cpart = ''
  let count = 0

  for (const line of lines) {
    if (count > 0) cpart += '\n'
    cpart += line

    count += line.length
    if (count < limit) continue

    parts.push(cpart)

    cpart = ''
    count = 0
  }

  if (cpart) parts.push(cpart)

  return parts
}

export class Czdata {
  ch_no: number
  chdiv: string

  lines: string[]
  title: string

  constructor(ch_no: number, chdiv = '', lines: string[] = []) {
    this.ch_no = ch_no
    this.chdiv = chdiv
    this.lines = lines
    this.title = lines[0]
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
  return text.replaceAll(/\t/g, '  ').replaceAll(/[!-~]/g, to_full).trim()
}

export interface Czopts {
  split_mode: number
  div_marker: string // mode 1: split by marker
  min_blanks: number // mode 2: split_slash
  need_blank: boolean // mode 3
  chdiv_labels: string //  mode 4
  custom_regex: string //  mode 5
  chunk_length: number //  mode 6
}

export class Cztext {
  ztext: string
  lines: string[]
  start: number
  chdiv: string
  error: string

  constructor(ztext: string, start = 1, chdiv = '') {
    this.ztext = ztext
    this.lines = ztext.split(/\r|\r?\n/)
    this.start = start
    this.chdiv = chdiv
  }

  valid_enough(chaps: Czdata[]) {
    if (chaps.length == 0 || this.error) return false

    for (const { title, chdiv } of chaps) {
      if (chdiv.length > 60) {
        this.error = `Lỗi: Tên bộ [${chdiv}] quá dài!`
        return false
      }
      if (title.length > 60) {
        this.error = `Lỗi: Tên chương [${title}] quá dài!`
        return false
      }
    }

    return true
  }

  split_text(opts: Czopts) {
    const mode = opts.split_mode
    if (mode == 0 || mode == 1) {
      const chaps = this.split_delim(opts.div_marker)
      if (this.valid_enough(chaps) || mode == 1) return chaps
    }

    if (mode == 0 || mode == 2) {
      const chaps = this.split_blank(opts.min_blanks)
      if (this.valid_enough(chaps) || mode == 2) return chaps
    }

    if (mode == 0 || mode == 3) {
      const chaps = this.split_block(opts.need_blank)
      if (this.valid_enough(chaps) || mode == 3) return chaps
    }

    if (mode == 0 || mode == 4) {
      const chaps = this.split_label(opts.chdiv_labels)
      if (this.valid_enough(chaps) || mode == 4) return chaps
    }

    if (mode == 0 || mode == 5) {
      const chaps = this.split_regex(opts.custom_regex)
      if (this.valid_enough(chaps) || mode == 5) return chaps
    }

    const parts = split_parts(this.lines.map((x) => x.trim()).filter(Boolean))

    return parts.map((cpart, index) => {
      return new Czdata(this.start + index, '', cpart.split('\n'))
    })
  }

  // split text by adding `///` before each chapter
  split_delim(div_marker = '///') {
    this.error = ''

    if (!this.ztext.includes(div_marker)) return []

    const input = this.lines.filter(Boolean)
    const chaps: Czdata[] = []

    let chdiv = this.chdiv
    let cbody: string[] = []

    const regex = new RegExp(`^${div_marker}${div_marker[0]}*(.*?)$`, 'u')
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

    // fast check if this method is valid
    if (!this.ztext.includes('\n'.repeat(min_blanks))) {
      return [] as Czdata[]
    }

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

    // fast check if this method is valid
    if (!/\n[\t\s　]/.test(this.ztext)) {
      return [] as Czdata[]
    }

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
    try {
      const regex = new RegExp(re_str)
      const is_title_fn = (line: string) => regex.test(line)
      return this.do_split(is_title_fn)
    } catch (ex) {
      this.error = ex
      return []
    }
  }

  do_split(is_title_fn: (line: string) => boolean) {
    this.error = ''

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
        this.error = `Lỗi dòng #${line_no + 1} (${line}): Chương trước trắng!`
        cbody.push(line)
        prev_was_chdiv = false
      } else if (cbody[0]) {
        chdiv = cbody[0]
        cbody[0] = line_trim
        prev_was_chdiv = true
      } else {
        cbody.push(line_trim)
        prev_was_chdiv = false
      }
    }

    if (cbody[0]) this.append(chaps, cbody, chdiv)

    return chaps
  }

  append(chaps: Czdata[], cbody: string[], chdiv = this.chdiv) {
    chaps.push(new Czdata(chaps.length + this.start, chdiv, cbody))
  }
}
