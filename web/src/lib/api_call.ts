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

export const api_get = (url: string, search?: URLSearchParams) => {
  return do_fetch(search ? `${url}?${search}` : url, { method: 'GET' })
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
  'nvinfos.index': '/api/books',
  'nvinfos.show': (id: any) => `/api/books/${id}`,
  'nvinfos.front': (id: any) => `/api/books/${id}/front`,

  // book seed
  'chroots.index': (book: any) => `/api/seeds/${book}`,
  'chroots.show': ([book, seed]) => `/api/seeds/${book}/${seed}`,
  'chroots.chaps': ([book, seed, page]) => `/api/seeds/${book}/${seed}/${page}`,

  // forum
  'dtopics.index': '/api/topics',
  'dtopics.show': (id: any) => `/api/topics/${id}`,

  'dtposts.index': '/api/tposts',

  // chivi users booklists
  'vilists.index': '/api/lists',
  'vilists.show': (id: any) => `/api/lists/${id}`,
  'vilists.': (id: any) => `/api/lists/${id}`,
  'vilists.create': '/api/lists',

  // chivi users book reviews
  'vicrits.index': '/api/crits',
  'vicrits.show': (id: any) => `/api/crits/${id}`,
  'vicrits.create': `/api/crits`,
  'vicrits.edit': (id: any) => `/api/crits/${id}/edit`,
  'vicrits.update': (id: any) => `/api/crits/${id}`,

  // reviews' replies
  'virepls.index': '/api/repls',

  // yousuu booklists
  'yslists.index': `/_ys/lists`,
  'yslists.show': (id: any) => `/_ys/lists/${id}`,

  // yosuu reviews
  'yscrits.index': `/_ys/crits`,
  'yscrits.show': (id: any) => `/_ys/crits/${id}`,
  'yscrits.repls': (id: any) => `/_ys/crits/${id}/repls`,

  // report convert errors
  'tlspec.qtran': '/api/qtran/mterror',
  'tlspec.create': '/api/tlspecs',
  'tlspec.update': (id: any) => `/api/tlspecs/${id}`,
  'tlspec.delete': (id: any) => `/api/tlspecs/${id}`,

  // glosssary v1
  'v1dict.index': '/api/dicts',
  'v1dict.show': (name: any) => `/api/dicts/${name}`,
}

type Extras = Record<string, any>

export const merge_query = (query?: URLSearchParams, extras: Extras = {}) => {
  const params = new URLSearchParams(query)
  for (const key in extras) params.set(key, extras[key])
  return params
}

// prettier-ignore
export const api_path = (path: string, args?: any, query?: URLSearchParams, extras?: Extras) => {
  const route = ROUTES[path]
  path = typeof route == 'function' ? route(args) : route || path

  if (extras) query = merge_query(query, extras)
  return query ? `${path}?${query}` : path
}
