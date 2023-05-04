declare namespace CV {
  interface Vicrit {
    user_id: number
    u_uname: string
    u_privi: number

    book_id: number
    b_uslug: string
    b_title: string

    list_id: number
    l_title: string
    l_uslug: string
    l_count: number

    vc_id: number
    stars: number
    ohtml: string
    btags: string[]

    ctime: number
    utime: number

    like_count: number
    repl_count: number

    me_liked: number
  }

  interface VicritList extends Paginate {
    crits: Array<Vicrit>
    books: Record<number, Wninfo>
  }

  interface VicritForm {
    id: number

    wn_id: number
    vl_id: number

    stars: number
    input: string
    btags: string
  }
}
