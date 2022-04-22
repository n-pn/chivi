declare namespace CV {
  interface Crbook {
    bslug: string

    btitle: string
    author: string

    bgenre: string
    bcover: string

    rating: number
    voters: number

    status: number
    update: number
  }

  interface Yscrit {
    book: Crbook

    id: string
    vhtml: string
    stars: number
    vtags: string[]

    uname: string
    uslug: string

    ctime: number
    utime: number

    like_count: number
    repl_count: number

    yslist_id?: string
    yslist_vname?: string
    yslist_count?: number
  }
}
