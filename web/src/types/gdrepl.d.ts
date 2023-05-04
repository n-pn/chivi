declare namespace CV {
  interface Gdrepl {
    user_id: number
    u_uname: string
    u_privi: number

    gdroot: number
    torepl: number
    touser: number

    rp_id: number
    level: number
    ohtml: string

    ctime: number
    utime: number

    like_count: number
    repl_count: number

    vcoin: number
    repls: Gdrepl[] = []

    me_liked: number
  }

  interface Rplist extends Paginate {
    repls: Array<Gdrepl>
  }
}
