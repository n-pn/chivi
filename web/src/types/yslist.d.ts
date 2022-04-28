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
}
