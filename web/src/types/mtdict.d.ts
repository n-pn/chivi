declare namespace CV {
  interface Cvdict {
    vd_id: number
    label: string

    brief: string
    dslug: string
  }

  interface Vidict {
    dname: string
    dtype: number

    label: string
    descs: string

    total: number
    mtime: number
  }

  interface Viterm {
    zstr: string
    cpos: string

    vstr: string
    attr: string

    uname: string
    mtime: number

    _lock: number
  }
}
