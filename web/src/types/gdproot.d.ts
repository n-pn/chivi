declare namespace CV {
  interface Gdroot {
    id: number
    rkey: string
    user_id: number

    dtype: string
    rlink: string
    title: string

    oname: string
    olink: string

    ctime: number
    utime: number

    like_count: number
    repl_count: number
    view_count: number
  }

  interface GdrootPage {
    gdroot: Gdroot
    rplist: Rplist
  }
}
