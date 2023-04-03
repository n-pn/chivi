declare namespace CV {
  interface Cvrepl {
    id: number

    user_id: number
    post_id: number
    repl_id: number

    ohtml: string

    ctime: number
    utime: number

    like_count: number
    repl_count: number

    repls: Cvrepl[] = []
  }

  interface Rplist {
    repls: Array<Cvrepl>

    users: Record<number, Cvuser>
    memos: Record<number, Memoir>

    pgidx: number
    pgmax: number
  }
}
