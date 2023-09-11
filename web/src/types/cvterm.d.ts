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

  interface Viterm {
    zstr: string
    cpos: string

    vstr: string
    attr: string

    uname: string
    mtime: number

    _lock: number
    _flag: number
  }
}
