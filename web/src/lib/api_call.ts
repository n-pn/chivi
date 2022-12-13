// import { browser } from '$app/environment'
import { error, redirect } from '@sveltejs/kit'

let my_fetch: CV.Fetch = globalThis.fetch
export const set_fetch = (fetch: CV.Fetch) => (my_fetch = fetch)

type REDIRECT_CODES = 300 | 301 | 302 | 303 | 304 | 305 | 306 | 307 | 308

export const do_fetch = async (
  url: string,
  init: RequestInit = { method: 'GET' }
) => {
  const resp = await my_fetch(url, init)
  const type = resp.headers.get('Content-Type')
  const data = type.includes('json') ? await resp.json() : await resp.text()

  if (resp.status < 300) return data
  if (resp.status > 308) throw error(resp.status, data)
  throw redirect(resp.status as REDIRECT_CODES, data)
}

export const build_params = (
  params?: URLSearchParams,
  extras: Record<string, any> = {},
  plucks: string[] = []
) => {
  if (params) Object.assign(extras, Object.entries(params))
  const output = new URLSearchParams(extras)
  for (const pluck in plucks) output.delete(pluck)
  return output
}

export const api_get = (url: string, search?: URLSearchParams) => {
  return do_fetch(`${url}?${search}`, { method: 'GET' })
}

type ReqBody = Record<string, any> | string
const json_headers = { 'Content-Type': 'application/json' }
const text_headers = { 'Content-Type': 'text/plain' }

export const api_call = (url: string, body: ReqBody, method = 'POST') => {
  if (typeof body === 'string') {
    const init = { method, body, headers: text_headers }
    return do_fetch(url, init)
  } else {
    const init = { method, body: JSON.stringify(body), headers: json_headers }
    return do_fetch(url, init)
  }
}

const PATHS = {
  'yslists.index': (_opts?: any) => `/_ys/lists`,
  'yslists.show': ({ list }) => `/_ys/lists/${list}`,
  'yscrits.index': (_opts?: any) => `/_ys/crits`,
  'ysrepls.index': ({ crit }) => `/_ys/crits/${crit}/repls`,
  'tlspec.qtran': () => '/api/qtran/mterror',
  'tlspec.create': () => '/api/tlspecs',
  'tlspec.update': ({ ukey }) => `/api/tlspecs/${ukey}`,
  'tlspec.delete': ({ ukey }) => `/api/tlspecs/${ukey}`,
}

export const api_path = (
  path: string,
  args: Record<string, any> = {},
  query?: URLSearchParams,
  extras: Record<string, any> = {},
  plucks: string[] = []
) => {
  const route = PATHS[path]
  if (!route) throw `Unknown route name ${path}`

  const params = new URLSearchParams(query)
  for (const [key, val] of Object.entries(extras)) params.set(key, val)
  for (const pluck in plucks) params.delete(pluck)
  return `${route(args)}?${params}`
}
