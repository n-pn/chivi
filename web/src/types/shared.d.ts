declare namespace CV {
  interface Paginate {
    pgidx: number
    pgmax: number
    total?: number
  }

  type Fetch = (url: RequestInfo, option?: RequestInit) => Promise<Response>
}