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
    hname: string
    vname: string

    author: Author
    bcover: string

    genres: string[]
    bintro: string[]
    nvseed: string[]

    status: number
    mftime: number

    voters: number
    rating: number

    ys_snvid: string
    pub_link: string
    pub_name: string
  }
}
