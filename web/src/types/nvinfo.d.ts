declare namespace CV {
  interface Author {
    zname: string
    vname: string
  }

  interface Wnlink {
    type: number
    name: string
    link: string
  }

  interface Wninfo {
    id: number
    bslug: string

    ztitle: string
    vtitle: string
    htitle: string

    zauthor: string
    vauthor: string

    bintro: string
    bcover: string

    genres: string[]
    labels: string[]

    status: number
    mftime: number

    voters: number
    rating: number

    origins: Wnlink[]
  }

  interface Crbook {
    id: number
    bslug: string

    vtitle: string
    vauthor: string

    bcover: string
    genres: string[]

    rating: number
    voters: number

    status: number
    mftime: number
  }

  interface WnForm {
    ztitle: string
    vtitle: string

    zauthor: string
    vauthor: string

    zintro: string
    vintro: string

    genres: string[]
    bcover: string
    status: number

    // labels: string[]
  }
}
