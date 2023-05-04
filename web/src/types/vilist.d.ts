declare namespace CV {
  interface Vilist {
    user_id: number
    u_uname: string
    u_privi: number

    vl_id: number
    tslug: string

    title: string
    dhtml: string

    genres: string[]
    covers: string[]

    ctime: number
    utime: number

    book_count: number
    view_count: number
    like_count: number

    me_liked: number

    // star_count: number
  }

  interface VilistList extends Paginate {
    lists: Vilist[]
    users: Record<number, Viuser>
  }

  interface VilistForm {
    id: number = 0

    title: string
    dtext: string
    klass: string
  }
}
