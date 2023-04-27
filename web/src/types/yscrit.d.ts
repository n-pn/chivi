declare namespace CV {
  interface Yscrit {
    id: number

    book_id: number
    user_id: number
    list_id: number

    vhtml: stringstring
    stars: number
    vtags: stringstring[]

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

  interface YscritFull {
    yu_id: number
    uname: string
    u_pic: string

    yc_id: number
    ctime: number
    utime: number

    stars: number
    btags: string[]
    vhtml: string

    like_count: number
    repl_count: number

    wn_slug: string
    yl_name: string
    yl_slug: string
    yl_bnum: number
  }
}
