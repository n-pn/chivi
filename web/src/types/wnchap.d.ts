declare namespace CV {
  interface Chmeta {
    sname: string
    total: number

    clink: string
    cpart: number

    _curr: string
    _prev: string
    _next: string
  }

  interface Zhchap {
    ztext: string
    cvmtl: string
    title: string
    //
    grant: boolean
    privi: number
    cpart: number
    //
    _path?: string
  }
}
