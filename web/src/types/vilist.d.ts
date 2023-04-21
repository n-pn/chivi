declare namespace CV {
  interface Vilist {
    id: number
    user_id: number

    title: string
    tslug: string

    genres: string[]
    covers: string[]

    dhtml: string
    utime: number

    book_count: number
    view_count: number
    like_count: number
    star_count: number
  }

  interface VilistList extends Paginate {
    lists: Vilist[]
    users: Record<number, Viuser>
  }
}
