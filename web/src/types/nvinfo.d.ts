declare namespace CV {
  interface Author {
    zname: string
    vname: string
  }

  interface Nvinfo {
    id: number

    bslug: string
    bhash: string

    zname: string
    vname: string

    btitle_hv: string

    author_zh: string
    author_vi: string

    scover: string
    bcover: string
    bintro: string

    genres: string[]
    snames: string[]

    status: number
    mftime: number

    voters: number
    rating: number

    ys_snvid: string
    pub_link: string
    pub_name: string
  }
}
