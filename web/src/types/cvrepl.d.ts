declare namespace CV {
  interface Cvrepl {
    id: number

    post_id: number
    repl_id: number

    u_dname: string
    u_privi: number

    ohtml: string

    ctime: number
    utime: number

    like_count: number
    repl_count: number

    self_liked?: boolean
    self_rp_ii?: number

    repls: Cvrepl[] = []
  }

  interface Tplist {
    items: Array<Cvrepl>
    pgidx: number
    pgmax: number
  }
}
