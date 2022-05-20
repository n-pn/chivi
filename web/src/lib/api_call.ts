type Output = Promise<[number, any]>
const headers = { 'Content-Type': 'application/json' }

export async function call_api(
  url: string,
  method = 'GET',
  body?: string | object,
  fetch: CV.Fetch = globalThis.fetch
): Output {
  if (typeof body == 'object') body = JSON.stringify(body)
  const res = await fetch(url, { method, headers, body })
  const type = res.headers.get('Content-Type')

  if (type.startsWith('text/plain')) {
    return [res.status, await res.text()]
  } else {
    return [res.status, await res.json()]
  }
}

type Cache = { maxage: number; private?: boolean }

export async function wrap_get(
  fetch: CV.Fetch,
  url: string,
  cache?: Cache,
  extra?: object
) {
  const [status, data] = await call_api(url, 'GET', null, fetch)

  if (status < 300) {
    if (extra) Object.assign(data, extra)
    return { props: data, cache }
  }

  return status >= 400 ? { status, error: data } : { status, redirect: data }
}
