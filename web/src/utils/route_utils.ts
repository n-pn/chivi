export function book_url(bslug: string, suffix = '') {
  return `/-${bslug}/${suffix}`
}

export function seed_url(bslug: string, sname = 'union', pgidx = 1) {
  const url = book_url(bslug, `chaps/${sname}`)
  return pgidx > 1 ? `${url}?pg=${pgidx}` : url
}

export function to_pgidx(chidx: number, count = 32) {
  return Math.floor((chidx - 1) / count) + 1
}

export function chap_url(bslug: string, { sname, chidx, uslug, cpart }) {
  if (chidx < 1) chidx = 1
  const index = cpart > 0 ? `${chidx}.${cpart}` : chidx.toString()
  return book_url(bslug, `chaps/${sname}/${index}-${uslug}`)
}
