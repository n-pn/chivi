declare namespace CV {
  interface Author {
    zname: string
    vname: string
  }

  interface Nvinfo {
    id: number

    bslug: string
    bhash: string

    btitle_zh: string
    btitle_hv: string
    btitle_vi: string

    author_zh: string
    author_vi: string

    bcover: string
    scover: string

    bintro: string
    genres: string[]
    labels: string[]

    status: number
    mftime: number

    voters: number
    rating: number

    ys_snvid: string
    pub_link: string
    pub_name: string
  }

  interface WnForm {
    btitle_zh: string
    btitle_vi: string

    author_zh: string
    author_vi: string

    bintro_zh: string
    bintro_vi: string

    genres: string[]
    bcover: string
    status: number

    // labels: string[]
  }
}
