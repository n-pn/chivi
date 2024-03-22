export interface Zchap {
  title: string
  chdiv: string
  lines: string[]
}

export function split_mode_0(input: string, repeat = 3) {
  const chaps: Zchap[] = []
  const lines = input.split('\n').filter(Boolean)

  let cpart: string[] = []
  let chdiv = ''

  const regex = new RegExp(`^\/{${repeat},}(.*?)$`, 'u')
  let found: RegExpMatchArray | null

  for (const line of lines) {
    found = line.match(regex)

    if (!found) {
      cpart.push(line.trim())
      continue
    }

    if (cpart.length > 0) {
      const [title, ...paras] = cpart
      chaps.push({ title, chdiv, lines: paras })

      // prettier-ignore
      if (chaps.length > 1000) throw "Có quá nhiều chương được chia, mời xem lại dữ liệu đầu vào!"
    }

    chdiv = found[1].trim() || chdiv
    cpart = []
  }

  if (cpart.length > 0) {
    const [title, ...paras] = cpart
    chaps.push({ title, chdiv, lines: paras })
  }

  return chaps
}

export function split_mode_1(input: string, min_blanks = 2, trim = false) {
  let blank_count = min_blanks

  const is_title_fn = (line: string) => {
    if (trim) line = clean_text(line)

    if (line) {
      const is_title = blank_count >= min_blanks
      blank_count = 0
      return is_title
    } else {
      blank_count += 1
      return false
    }
  }

  return split_text(input, is_title_fn)
}

export function split_mode_2(input: string, blank_before = false) {
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

  return split_text(input, is_title_fn)
}

const hannum = '零〇一二两三四五六七八九十百千'
export function split_mode_3(input: string, labels: string) {
  const regex = new RegExp(`^[ 　]*第[\\d${hannum}]+[${labels}]`)
  const is_title_fn = (line: string) => regex.test(line)
  return split_text(input, is_title_fn)
}

export function split_mode_4(input: string, re_str: string) {
  const regex = new RegExp(re_str)
  const is_title_fn = (line: string) => regex.test(line)
  return split_text(input, is_title_fn)
}

const clean_text = (text: string) => text.replaceAll(/[\t\s\u3000]/g, ' ').trim()

function split_text(input: string, is_title_fn: (line: string) => boolean) {
  const lines = input.split('\n')
  const chaps: Zchap[] = []

  let chdiv = ''
  let prev_was_chdiv = false

  let pending: Zchap = { chdiv, title: '', lines: [] }

  for (let line of lines) {
    const is_title = is_title_fn(line)
    const clean_line = clean_text(line)
    if (!clean_line) continue

    if (!is_title) {
      if (pending.title) pending.lines.push(clean_line)
      else pending.title = clean_line
    } else if (pending.lines.length > 0) {
      chaps.push(pending)
      pending = { chdiv, title: clean_line, lines: [] }
      prev_was_chdiv = false
    } else if (prev_was_chdiv) {
      throw `Lỗi dòng [${line}]: Chương phía trước không có nội dung!`
    } else if (!pending.title) {
      pending.title = clean_line
      prev_was_chdiv = false
    } else {
      pending.chdiv = chdiv = pending.title
      pending.title = clean_line
      prev_was_chdiv = true
    }
  }

  if (pending.title) chaps.push(pending)

  return chaps
}
