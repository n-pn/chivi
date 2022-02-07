export class Pager {
  constructor(url, dfs = { pg: 1 }) {
    this.url = url
    this.dfs = dfs
  }

  get_al(value) {
    return this.url.searchParams.get(value) || this.dfs[value]
  }

  get path() {
    return this.url.pathname
  }

  gen_url(opts = {}) {
    const query = new URLSearchParams(this.url.searchParams)

    for (const key in opts) {
      const val = opts[key]
      if (val && val != this.dfs[key]) {
        query.set(key, val)
      } else {
        query.delete(key)
      }
    }

    const qs = query.toString()
    return qs ? this.url.pathname + '?' + qs : this.url.pathname
  }
}
