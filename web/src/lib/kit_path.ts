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
  sroot: string,
  ch_no: number | string,
  { p_idx = 1, rmode = 'qt', qt_rm = 'qt_v1', mt_rm = 'mtl_1' } = {}
) {
  const cpath = p_idx > 1 ? `${sroot}/${ch_no}_${p_idx}` : `${sroot}/${ch_no}`

  const params = new URLSearchParams()
  if (rmode != 'qt') params.append('rm', rmode)
  if (qt_rm != 'qt_v1') params.append('qt', qt_rm)
  if (mt_rm != 'mtl_1') params.append('mt', mt_rm)

  const search = params.toString()
  return search ? `${cpath}?${search}` : cpath
}

export function _pgidx(index: number, limit = 32) {
  return Math.floor((index - 1) / limit) + 1
}
