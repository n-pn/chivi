export class Pager {
  url: URL
  omit: object

  constructor(url: URL, omit: Record<string, any> = { pg: 1 }) {
    this.url = url
    this.omit = omit
  }

  get path(): string {
    return this.url.pathname
  }

  get(value: string) {
    return this.url.searchParams.get(value) || this.omit[value]
  }

  gen_url(opts = {}): string {
    const query = new URLSearchParams(this.url.searchParams)

    for (const key in opts) {
      const val = opts[key]
      if (val && val != this.omit[key]) {
        query.set(key, val)
      } else {
        query.delete(key)
      }
    }

    const qs = query.toString()
    return qs ? this.url.pathname + '?' + qs : this.url.pathname
  }
}
