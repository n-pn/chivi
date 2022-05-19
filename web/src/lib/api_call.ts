type Output = Promise<[number, any]>
type Params = Record<string, any>
const headers = { 'Content-Type': 'application/json' }

// prettier-ignore
export async function api_call(fetch: CV.Fetch, path: string, body?: Params, method = 'GET'): Output {
  const opts = { method, headers, body: body ? JSON.stringify(body) : null }
  const res = await fetch(`/api/${path}`, opts)
  const data = await res.json()
  return res.ok ? [0, data.props] : [res.status, data.error]
}

export async function put(url: string, body: Params, fetch?: CV.Fetch) {
  await api_call(fetch || globalThis.fetch, url, body, 'PUT')
}

export async function call_api(
  url: string,
  method = 'GET',
  body?: string | object,
  fetch: CV.Fetch = globalThis.fetch
) {
  if (typeof body == 'object') body = JSON.stringify(body)
  const res = await fetch(url, { method, headers, body })
  const type = res.headers.get('Content-Type')

  if (type.startsWith('text/plain')) {
    return [res.status, await res.text()]
  } else {
    return [res.status, await res.json()]
  }
}
