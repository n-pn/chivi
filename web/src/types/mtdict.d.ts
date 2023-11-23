declare namespace CV {
  interface Cvdict {
    vd_id: number
    label: string

    brief: string
    dslug: string
  }

  interface Zvdict {
    name: string
    kind: number
    d_id: number

    p_min: numbrt
    label: string
    brief: string

    total: number
    mtime: number
    users: string[]
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
