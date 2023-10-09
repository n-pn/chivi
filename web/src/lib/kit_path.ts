export function scrub_params(
  params: URLSearchParams,
  ommits: Record<string, any>
) {
  for (const [name, ommit] of Object.entries(ommits)) {
    const param = params.get(name)
    if (param == ommit) params.delete(name)
  }
  return params
}

export const stem_path = (sroot: string, pg_no = 1) => {
  if (pg_no < 33) return sroot
  return `${sroot}?pg=${_pgidx(pg_no)}`
}

export function book_path(bslug: string, child: string = '') {
  return child ? `/wn/${bslug}/${child}` : `/wn/${bslug}`
}

export function seed_path(bslug: string, sname: string, pg_no = 0): string {
  const path = `/wn/${bslug}/ch${sname}`
  return pg_no > 1 ? path + `?pg=${pg_no}` : path
}

const seed_prefixes = ['~', '@', '!', '+']
// prettier-ignore
export const fix_sname = (sname: string) => {
  return seed_prefixes.includes(sname[0]) ? sname : '~avail'
}

export function chap_path(
  root: string,
  chap: number | string,
  { rtype = 'qt', qt_rm = 'qt_v1', mt_rm = 'mtl_1' } = {}
) {
  const href = `${root}/${chap}`

  const params = new URLSearchParams()
  if (rtype != 'qt') params.append('rm', rtype)
  if (qt_rm != 'qt_v1') params.append('qt', qt_rm)
  if (mt_rm != 'mtl_1') params.append('mt', mt_rm)

  const search = params.toString()
  return search ? `${href}?${search}` : href
}

export function _pgidx(index: number, limit = 32) {
  return Math.floor((index - 1) / limit) + 1
}
