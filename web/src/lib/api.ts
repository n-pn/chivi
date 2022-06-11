import { browser } from '$app/env'

class Error {
  status: number
  error: string

  constructor(status: number, error: string) {
    this.status = status
    this.error = error
  }
}

interface Cached<T> {
  val: T | Error
  ttl: number
}

// type CachedMap<T> = Map<string, Cached<T>>

function load_cached<T>(map: Map<string, Cached<T>>, key: string, ttl: number) {
  // if (!browser) return null

  let cached = map.get(key)
  return cached && cached.ttl > ttl ? cached : null
}

export class API {
  fetch: CV.Fetch
  uname: string

  maps = {
    nslists: new Map<string, Cached<CV.Nvseed[]>>(),
    nvseeds: new Map<string, Cached<CV.Nvseed>>(),
  }

  constructor(fetch: CV.Fetch, session: App.Session) {
    this.fetch = fetch
    this.uname = session.uname
  }

  uncache(map_name: string, key: string) {
    this.maps[map_name].delete(key)
  }

  async nslist(bslug: string) {
    const map = this.maps.nslists
    const url = `/api/seeds/${bslug}`
    return await this.get(map, bslug, url, 300)
  }

  async nvseed(bslug: string, sname: string) {
    const map = this.maps.nslists
    const key = `${bslug}/${sname}`
    const url = `/api/seeds/${key}`
    return await this.get(map, key, url, 180)
  }

  async get<T>(
    map: Map<string, Cached<T>>,
    key: string,
    url: string,
    ttl: number
  ) {
    const now = Math.floor(new Date().getTime() / 1000)

    const cached = map.get(key)
    if (cached && cached.ttl > now) return cached.val

    const res = await this.call(url, 'GET')
    map.set(key, { val: res, ttl: now + (browser ? ttl : ttl / 60) })

    return res
  }

  async call(url: string, method = 'GET') {
    const res = await this.fetch(url, { method })
    if (res.ok) return await res.json()
    return new Error(res.status, await res.text())
  }
}
