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
  return seed_prefixes.includes(sname[0]) ? sname : '~draft'
}

const default_rmode = {
  ai: 'avail',
  qt: 'mt_v1',
  ht: 'plain',
  cf: 'add_term',
}

export function chap_path(
  root: string,
  chap: number | string,
  { rtype, rmode }
) {
  let href = `${root}/${chap}`
  if (rtype != 'ai') href += '/' + rtype

  const params = new URLSearchParams()

  if (rmode && rmode != default_rmode[rtype]) params.append('mode', rmode)

  const search = params.toString()
  return search ? `${href}?${search}` : href
}

export function _pgidx(index: number, limit = 32) {
  return Math.floor((index - 1) / limit) + 1
}
