declare namespace CV {
  interface Gdrepl {
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
    repls: Gdrepl[] = []
  }

  interface Rplist extends Paginate {
    repls: Array<Gdrepl>
    users: Record<number, Cvuser>
    memos: Record<number, Memoir>
  }
}
