declare namespace CV {
  interface Dtpost {
    id: number
    no: string
    dt: string

    db_bname: string
    db_bslug: string

    dt_title: string
    dt_tslug: string

    u_dname: string
    u_privi: number

    rp_id: number
    rp_no: string

    ru_dname: string
    ru_privi: number

    ohtml: string
    odesc: string

    state: number
    ctime: number
    utime: number

    edit_count: number
    like_count: number
    repl_count: number
  }
}
