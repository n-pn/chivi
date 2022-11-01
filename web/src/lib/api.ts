import { browser } from '$app/environment'
import { error, redirect } from '@sveltejs/kit'

interface Cached<T> {
  val: T
  ttl: number
}

type GetParams = Record<string, string>

// prettier-ignore
export async function api_call( url: string, method = 'PUT', body?: object, fetch = globalThis.fetch ) {
  const options = { method }

  if (body) {
    options['headers'] = { 'Content-Type': 'application/json' }
    options['body'] = JSON.stringify(body)
  }

  const res = await fetch(url, options)
  if (!res.ok) {
    const message = await res.text()
    if (res.status >= 400) throw error(res.status, message)
    else throw redirect(res.status, encodeURI(message))
  }

  const type = res.headers.get('Content-Type')
  return type.startsWith('text') ? await res.text() : await res.json()
}

// prettier-ignore
export async function api_get( url: string, params?: GetParams, fetch = globalThis.fetch ) {
  if (params) url += '?' + new URLSearchParams(params).toString()
  return await api_call(url, 'GET', null, fetch)
}

// prettier-ignore
export async function api_put( url: string, body?: object, fetch = globalThis.fetch ) {
  return await api_call(url, 'PUT', body, fetch)
}

// prettier-ignore
export async function cache_get<T>( map: Map<string | number, Cached<T>>, key: string | number, url: string, ttl: number, fetch: CV.Fetch ) {
  const now = Math.floor(new Date().getTime() / 1000)

  const cached = map.get(key)
  if (cached && cached.ttl > now) return cached.val

  const res = await api_get(url, null, fetch)
  map.set(key, { val: res, ttl: now + (browser ? ttl : 5) })

  return res
}

interface Nvbook {
  nvinfo: CV.Nvinfo
  ubmemo: CV.Ubmemo
}

const cache_maps = {
  nvbooks: new Map<string, Cached<Nvbook>>(),
  nslists: new Map<number, Cached<CV.Nslist>>(),
  nvseeds: new Map<string, Cached<CV.Chroot>>(),
}

export function uncache(map_name: string, key: string | number) {
  const map = cache_maps[map_name]
  if (map) map.delete(key)
  else console.error(`map_name : ${map_name} not found!`)
}

// prettier-ignore
export async function get_nvbook(bslug: string, fetch = globalThis.fetch) : Promise<Nvbook> {
  const url = `/api/books/${bslug}`
  return await cache_get<Nvbook>(cache_maps.nvbooks, bslug, url, 300, fetch)
}

export async function get_nslist(nv_id: number, fetch = globalThis.fetch) {
  const map = cache_maps.nslists
  const url = `/api/seeds/${nv_id}`
  return await cache_get<CV.Nslist>(map, nv_id, url, 300, fetch)
}

// prettier-ignore
export async function get_nvseed(nv_id: number, sname: string, mode = 0, fetch = globalThis.fetch) {
  const map = cache_maps.nvseeds
  const key = `${nv_id}/${sname}`

  let url = `/api/seeds/${key}`
  if (mode > 0) {
    map.delete(key)
    url += '?mode=' + mode
  }
  return await cache_get(map, key, url, 180, fetch)
}

// prettier-ignore
export async function get_chlist(nv_id: number, sname: string, pgidx = 1, fetch = globalThis.fetch) {
  const key = `${nv_id}/${sname}/${pgidx}`
  const url = `/api/seeds/${key}`
  return await api_get(url, null, fetch)
}
