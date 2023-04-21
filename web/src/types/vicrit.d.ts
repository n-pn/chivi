declare namespace CV {
  interface Vicrit {
    id: number

    book_id: number
    user_id: number
    list_id: number

    stars: number
    ohtml: string
    btags: string[]

    ctime: number
    edited: boolean = false

    like_count: number
    repl_count: number
  }

  interface VicritList extends Paginate {
    crits: Array<Vicrit>
    books: Record<number, Wninfo>
    users: Record<number, Viuser>
    lists: Record<number, Vilist>
  }

  interface VicritForm {
    id: number

    wn_id: number
    bl_id: number

    stars: number
    input: string
    btags: string
  }
}
