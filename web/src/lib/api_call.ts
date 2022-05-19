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
