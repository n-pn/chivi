declare namespace CV {
  interface Paginate {
    pgidx: number = 1
    pgmax?: number = 1
    total?: number = 1
  }

  type Fetch = (url: RequestInfo, option?: RequestInit) => Promise<Response>
}
