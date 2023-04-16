declare namespace CV {
  interface Murepl {
    id: number

    user_id: number
    head_id: number

    torepl_id: number
    touser_id: number

    ohtml: string
    level: number

    ctime: number
    utime: number

    like_count: number
    repl_count: number

    vcoin: number
    repls: Murepl[] = []
  }

  interface Rplist {
    repls: Array<Murepl>

    users: Record<number, Cvuser>
    memos: Record<number, Memoir>

    pgidx: number
    pgmax: number
  }
}
