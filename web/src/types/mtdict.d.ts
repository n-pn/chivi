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

  interface Zvpair {
    dname: string
    a_key: string
    b_key: string

    a_vstr: string
    a_attr: string
    b_vstr: string
    b_attr: string

    uname: string
    mtime: number
  }
}
