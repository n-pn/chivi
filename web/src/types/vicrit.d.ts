declare namespace CV {
  interface Vicrit {
    id: string
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

  interface VicritList {
    pgidx: number
    pgmax: number

    crits: Array<Vicrit>
    books: Record<number, Nvinfo>
    users: Record<number, Viuser>
    lists: Record<number, Vilist>
  }

  interface VicritForm {
    id: number
    stars: number
    input: string
    btags: string
  }
}
