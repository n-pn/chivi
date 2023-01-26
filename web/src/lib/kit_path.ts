import { slugify } from '$utils/text_utils'

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

export function book_path(id: string | number, bname: string = '') {
  const base = `/wn/${id}-${slugify(bname)}`

  return {
    index: base,
    child: (path: string) => `${base}/${path}`,
  }
}

export function _pgidx(index: number, limit = 32) {
  return Math.floor((index - 1) / limit) + 1
}

export function seed_path(
  bslug: string,
  sname: string,
  s_bid: string | number,
  ch_no: number = 0
): string {
  let path = `/wn/${bslug}/chaps/${sname}`
  if (sname[0] == '!') path += `:${s_bid}`

  return ch_no > 32 ? (path += `?pg=${_pgidx(ch_no, 32)}`) : path
}
