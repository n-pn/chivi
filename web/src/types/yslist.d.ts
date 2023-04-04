declare namespace CV {
  interface Yslist {
    id: string

    uslug: string
    yl_id: string

    user_id: number

    vname: string
    vdesc: string
    class: string

    genres: string[]
    covers: string[]

    ctime: number
    utime: number

    book_count: number
    view_count: number

    like_count: number
    star_count: number
  }

  interface YslistList extends Paginate {
    lists: Yslist[]
    users: Record<number, Ysuser>
  }
}
