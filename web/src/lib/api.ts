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

export class API {
  fetch: CV.Fetch
  uname: string

  maps = {
    nvinfos: new Map<string, Cached<CV.Nvinfo>>(),
    nslists: new Map<number, Cached<CV.Nslist>>(),
    nvseeds: new Map<string, Cached<CV.Chroot>>(),
  }

  constructor(fetch: CV.Fetch, session: App.Session) {
    this.fetch = fetch
    this.uname = session.uname
  }

  uncache(map_name: string, key: string) {
    const map = this.maps[map_name]
    if (map) map.delete(key)
    else console.error(`map_name : ${map_name} not found!`)
  }

  async nvbook(bslug: string) {
    const map = this.maps.nvinfos
    const url = `/api/books/${bslug}`
    return await this.get<CV.Nvinfo>(map, bslug, url, 300)
  }

  async nslist(nv_id: number) {
    const map = this.maps.nslists
    const url = `/api/seeds/${nv_id}`
    return await this.get<CV.Nslist>(map, nv_id, url, 300)
  }

  async nvseed(nv_id: number, sname: string, mode = 0) {
    const map = this.maps.nvseeds
    const key = `${nv_id}/${sname}`

    let url = `/api/seeds/${key}`
    if (mode > 0) {
      map.delete(key)
      url += '?mode=' + mode
    }
    return await this.get(map, key, url, 180)
  }

  async chlist(nv_id: number, sname: string, pgidx = 1) {
    const key = `${nv_id}/${sname}/${pgidx}`
    const url = `/api/seeds/${key}`
    return await this.call(url)
  }

  async get<T>(
    map: Map<string | number, Cached<T>>,
    key: string | number,
    url: string,
    ttl: number
  ) {
    const now = Math.floor(new Date().getTime() / 1000)

    const cached = map.get(key)
    if (cached && cached.ttl > now) return cached.val

    const res = await this.call(url, 'GET')
    map.set(key, { val: res, ttl: now + (browser ? ttl : 5) })

    return res
  }

  async call(url: string, method = 'GET', body?: object) {
    const options = { method }
    if (body) {
      options['headers'] = { 'Content-Type': 'application/json' }
      options['body'] = JSON.stringify(body)
    }

    const res = await this.fetch(url, options)
    if (!res.ok) return new Error(res.status, await res.text())

    const type = res.headers.get('Content-Type')
    return type.startsWith('text') ? await res.text() : await res.json()
  }
}
