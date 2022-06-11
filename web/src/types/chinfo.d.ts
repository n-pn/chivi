declare namespace CV {
  interface Chinfo {
    chidx: number
    title: string
    chvol: string
    uslug: string

    chars: number
    parts: number
    utime: number
    uname: string

    o_sname?: string
    o_snvid?: string
    o_chidx?: number
  }

  interface Chlist extends Paginate {
    chaps: Chinfo[]
  }
}
