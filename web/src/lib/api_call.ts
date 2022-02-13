type Output = Promise<[number, any]>

const headers = { 'Content-Type': 'application/json' }

// prettier-ignore
export async function api_call(fetch: CV.Fetch, path: string, body?: object, method = 'GET'): Output {
  const opts = { method, headers, body: body ? JSON.stringify(body) : null }
  const res = await fetch(`/api/${path}`, opts)
  const data = await res.json()
  return res.ok ? [0, data.props] : [res.status, data.error]
}
