declare namespace CV {
  interface Vicrit {
    vc_id: number
    vu_id: number
    vl_id: number
    wn_id: number

    u_uname: string
    u_privi: number

    b_uslug: string
    b_title: string

    l_title: string
    l_uslug: string
    l_count: number

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

  interface CritFilter {
    og: string
    by: string
    wn: string
    bl: string

    gt: number
    lt: number
    pg: number
    _s: string
    _m: string
  }
}
