declare namespace CV {
  interface Yslist {
    id: string

    op_id: number
    uname: string
    uslug: string

    vname: string
    vslug: string

    vdesc: string
    class: string

    genres: string[]
    covers: string[]

    book_count: number
    view_count: number
    like_count: number
    star_count: number

    ctime: number
    utime: number
  }

  interface YslistList {
    pgidx: number
    pgmax: number
    yl_id: number
    lists: Yslist[]
    crits: Yscrit[]
    books: Record<number, CrBook>
  }
}
