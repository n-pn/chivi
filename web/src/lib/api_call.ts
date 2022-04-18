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
