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

const seed_prefixes = ['_', '@', '!', '+']

export function seed_path(
  bslug: string,
  sname: string,
  s_bid: string | number,
  pg_no: number = 0
): string {
  if (!seed_prefixes.includes(sname[0])) sname = '_'
  else if (s_bid && sname[0] == '!') sname += `:${s_bid}`

  const path = `/wn/${bslug}/chaps/${sname}`
  return pg_no > 1 ? path + `?pg=${pg_no}` : path
}

export function chap_path(bslug: string, { sname, snvid }, ch_no: number) {
  return `${seed_path(bslug, sname, snvid)}/${ch_no}`
}

export function _pgidx(index: number, limit = 32) {
  return Math.floor((index - 1) / limit) + 1
}
