declare namespace CV {
  interface Upinfo {
    id: number
    viuser_id: number
    wninfo_id: number

    zname: string
    vname: string
    uslug: string

    vintro: string
    labels: string[]

    mtime: number
    guard: number

    chap_count: number
    word_count: number
  }
}
