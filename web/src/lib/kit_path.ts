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
