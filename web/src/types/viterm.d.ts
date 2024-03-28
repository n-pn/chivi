declare namespace CV {
  interface Cvterm {
    id: number

    dic: number
    tab: number

    key: string
    val: string

    ptag: string
    prio: number

    uname: string
    mtime: number

    state: string
  }

  interface Zvdefn {
    dict: string
    zstr: string
    cpos: string

    vstr: string
    attr: string

    user: string
    time: number
    lock: number
  }

  export type Cvtree = [
    string, // cpos
    string, // attr
    number, // from
    number, // upto
    string | Array<Cvtree>, // vstr or children
    number // dnum
  ]
}
