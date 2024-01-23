// import { browser } from '$app/environment'
import { error, redirect, type NumericRange } from '@sveltejs/kit'

type REDIRECT_CODES = 300 | 301 | 302 | 303 | 304 | 305 | 306 | 307 | 308

export const do_fetch = async (
  path: string,
  init: RequestInit,
  fetch: CV.Fetch
) => {
  const resp = await fetch(path, init)
  const type = resp.headers.get('content-type') || ''
  const data = type.includes('json') ? await resp.json() : await resp.text()

  if (resp.status < 300) return data
  if (resp.status >= 400)
    throw error(resp.status as NumericRange<400, 599>, data)
  throw redirect(resp.status as REDIRECT_CODES, data)
}

export function api_get<T>(
  path: string,
  fetch: CV.Fetch = globalThis.fetch
): Promise<T> {
  return do_fetch(path, { method: 'GET' }, fetch)
}

type ReqBody = Record<string, any> | string
const json_headers = { 'Content-Type': 'application/json' }
const text_headers = { 'Content-Type': 'text/plain' }

export const api_call = (
  path: string,
  body: ReqBody,
  method: string = 'POST',
  fetch: CV.Fetch = globalThis.fetch
) => {
  if (typeof body === 'string') {
    const init = { method, body, headers: text_headers }
    return do_fetch(path, init, fetch)
  } else {
    const init = { method, body: JSON.stringify(body), headers: json_headers }
    return do_fetch(path, init, fetch)
  }
}

type Extras = Record<string, any>

export const merge_query = (query?: URLSearchParams, extras: Extras = {}) => {
  const params = new URLSearchParams(query)
  for (const key in extras) {
    const val = extras[key]
    if (val) params.set(key, val)
  }
  return params
}
