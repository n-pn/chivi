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

export function seed_path(
  bslug: string,
  sname: string,
  pg_no: number = 0
): string {
  const path = `/wn/${bslug}/chaps/${sname}`
  return pg_no > 1 ? path + `?pg=${pg_no}` : path
}

const seed_prefixes = ['_', '@', '!', '+']
// prettier-ignore
export const fix_sname = (sname: string) => {
  return seed_prefixes.includes(sname[0]) ? sname : '_'
}

export function chap_path(
  bslug: string,
  sname: string,
  ch_no: number,
  cpart = 1,
  uslug = ''
) {
  if (cpart > 1) {
    return `${seed_path(bslug, sname)}/${ch_no}_${cpart}-${uslug}`
  } else {
    return `${seed_path(bslug, sname)}/${ch_no}-${uslug}`
  }
}

export function _pgidx(index: number, limit = 32) {
  return Math.floor((index - 1) / limit) + 1
}
