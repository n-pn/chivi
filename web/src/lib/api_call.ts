// import { browser } from '$app/environment'
import { error, redirect } from '@sveltejs/kit'

let my_fetch: CV.Fetch = globalThis.fetch
export const set_fetch = (fetch: CV.Fetch) => (my_fetch = fetch)

type REDIRECT_CODES = 300 | 301 | 302 | 303 | 304 | 305 | 306 | 307 | 308

export const do_fetch = async (
  url: string,
  init: RequestInit = { method: 'GET' },
  fetch: CV.Fetch = my_fetch
) => {
  const resp = await fetch(url, init)
  const type = resp.headers.get('content-type') || ''
  const data = type.includes('json') ? await resp.json() : await resp.text()

  if (resp.status < 300) return data
  if (resp.status > 308) throw error(resp.status, data)
  throw redirect(resp.status as REDIRECT_CODES, data)
}

export function api_get<T>(url: string, fetch?: CV.Fetch): Promise<T> {
  return do_fetch(url, { method: 'GET' }, fetch || my_fetch)
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

export const ROUTES = {
  // book info
  'wnovels.index': '/_db/books',
  'wnovels.show': (id: any) => `/_db/books/${id}/show`,
  'wnovels.front': (id: any) => `/_db/books/${id}/front`,
  'wnovels.edit': (id: any) => `/_db/books/${id}/+edit`,

  // forum
  'dtopics.index': '/_db/topics',
  'dtopics.show': (id: any) => `/_db/topics/${id}`,

  // chivi users booklists
  'vilists.index': '/_db/lists',
  'vilists.show': (id: any) => `/_db/lists/${id}`,
  'vilists.edit': (id: any) => `/_db/lists/${id}`,
  'vilists.create': '/_db/lists',

  // chivi users book reviews
  'vicrits.index': '/_db/crits',
  'vicrits.create': `/_db/crits`,
  'vicrits.show': (id: any) => `/_db/crits/${id}`,
  'vicrits.edit': (id: any) => `/_db/crits/${id}/edit`,
  'vicrits.update': (id: any) => `/_db/crits/${id}`,

  // yosuu reviews

  'yscrits.show': (id: any) => `/_ys/crits/${id}`,
  'yscrits.repls': (id: any) => `/_ys/crits/${id}/repls`,

  // report convert errors
  'tlspec.qtran': '/_db/qtran/mterror',
  'tlspec.create': '/_db/tlspecs',
  'tlspec.update': (id: any) => `/_db/tlspecs/${id}`,
  'tlspec.delete': (id: any) => `/_db/tlspecs/${id}`,

  // glosssary v1
  'v1dict.index': '/_m1/dicts',
  'v1dict.show': (name: string) => `/_m1/dicts/${name}`,
  'v1defn.index': '/_m1/defns',
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

// prettier-ignore
export const api_path = (path: string, args?: any, query?: URLSearchParams, extras?: Extras) => {
  const route = ROUTES[path]
  path = typeof route == 'function' ? route(args) : route || path

  if (extras) query = merge_query(query, extras)
  return query ? `${path}?${query}` : path
}
