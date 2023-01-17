declare namespace CV {
  interface Crbook {
    id: number

    bslug: string

    btitle: string
    author: string

    bgenre: string
    bcover: string
    scover: string

    rating: number
    voters: number

    status: number
    update: number
  }

  interface Yscrit {
    id: string
    wn_id: number

    vhtml: string
    stars: number
    vtags: string[]

    op_id: number
    uname: string
    uslug: string

    ctime: number
    utime: number

    like_count: number
    repl_count: number

    yslist_id?: string

    yslist_vname?: string
    yslist_vslug?: string

    yslist_class?: string
    yslist_count?: number
  }

  interface YscritList {
    pgidx: number
    pgmax: number
    crits: Yscrit[]
    books: Record<number, CrBook>
  }
}
