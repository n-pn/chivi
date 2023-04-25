declare namespace CV {
  interface Rproot {
    user_id: number

    id: number
    rkey: string

    type: string
    name: string
    link: string
    desc: string

    ctime: number
    utime: number

    like_count: number
    repl_count: number
    view_count: number
  }

  interface RprootPage {
    rproot: Rproot
    rplist: Rplist
  }
}
