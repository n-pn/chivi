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

const default_rmode = {
  qt: 'mt_v1',
  mt: 'mtl_1',
}

export function chap_path(
  root: string,
  chap: number | string,
  { rtype, rmode }
) {
  const href = `${root}/${chap}`

  const params = new URLSearchParams()

  if (rtype != 'qt') params.append('rm', rtype)
  if (rmode && rmode != default_rmode[rtype]) params.append('mode', rmode)

  const search = params.toString()
  return search ? `${href}?${search}` : href
}

export function _pgidx(index: number, limit = 32) {
  return Math.floor((index - 1) / limit) + 1
}
