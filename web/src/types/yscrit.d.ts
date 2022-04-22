declare namespace CV {
  interface Yscrit {
    id: string
    vhtml: string
    stars: number
    vtags: string[]

    uname: string
    uslug: string

    bid: string
    bname: string
    bslug: string
    author: string
    bgenre: string

    mftime: number
    like_count: number
    repl_count: number

    yslist_id?: string
    yslist_vname?: string
    yslist_count?: number
  }
}
