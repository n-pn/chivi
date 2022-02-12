export class Pager {
  url: URL
  dfs: object

  constructor(url: URL, dfs = { pg: 1 }) {
    this.url = url
    this.dfs = dfs
  }

  get path(): string {
    return this.url.pathname
  }

  get_val(value: string) {
    return this.url.searchParams.get(value) || this.dfs[value]
  }

  gen_url(opts = {}): string {
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
