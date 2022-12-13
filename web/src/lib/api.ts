// export const cache_get = async <T>(
//   name: string,
//   key: string | number,
//   url: string,
//   ttl: number,
//   fetch: CV.Fetch
// ): Promise<T> => {
//   const map = (cache_maps[name] ||= new Map<string | number, Cached<T>>())
//   const now = Math.floor(new Date().getTime() / 1000)

//   const cached = map.get(key)
//   if (cached && cached.ttl > now) return cached.val as T

//   const res = await api_get(url, null, fetch)
//   map.set(key, { val: res, ttl: now + (browser ? ttl : 1) })

//   return res as T
// }

// interface Nvbook {
//   nvinfo: CV.Nvinfo
//   ubmemo: CV.Ubmemo
// }

// export function uncache(name: string, key: string | number) {
//   const map = cache_maps[name]
//   if (map) map.delete(key)
//   else console.error(`uncache error: ${name} map not found!`)
// }

// // prettier-ignore
// export async function get_nvbook(bslug: string, fetch = globalThis.fetch) : Promise<Nvbook> {
//   const url = `/api/books/${bslug}`
//   return await cache_get<Nvbook>('nvbooks', bslug, url, 300, fetch)
// }

// export async function get_nslist(nv_id: number, fetch = globalThis.fetch) {
//   const url = `/api/seeds/${nv_id}`
//   return await cache_get<CV.Nslist>('nslists', nv_id, url, 300, fetch)
// }

// // prettier-ignore
// export async function get_nvseed(nv_id: number, sname: string, mode = 0, fetch = globalThis.fetch) {
//   const map = cache_maps.nvseeds
//   const key = `${nv_id}/${sname}`

//   let url = `/api/seeds/${key}`
//   if (mode > 0) {
//     map.delete(key)
//     url += '?mode=' + mode
//   }
//   return await cache_get(map, key, url, 180, fetch)
// }

// // prettier-ignore
// export async function get_chlist(nv_id: number, sname: string, pgidx = 1, fetch = globalThis.fetch) {
//   const key = `${nv_id}/${sname}/${pgidx}`
//   const url = `/api/seeds/${key}`
//   return await api_get(url, null, fetch)
// }

// type Extra = Record<string, string | number>
// export function merge_search(query: URLSearchParams, extra: Extra = {}) {
//   for (const [key, val] of Object.entries(extra)) {
//     if (val) query.append(key, val.toString())
//   }
//   return query
// }
