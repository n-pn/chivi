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

    user_id: number
    list_id: number

    vhtml: string
    stars: number
    vtags: string[]

    ctime: number
    utime: number

    like_count: number
    repl_count: number
  }

  interface YscritList extends Paginate {
    crits: Yscrit[]
    books: Record<number, CrBook>
    users: Record<number, Ysuser>
    lists: Record<number, Yslist>
  }
}
