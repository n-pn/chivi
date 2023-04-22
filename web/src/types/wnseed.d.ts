declare namespace CV {
  interface Chroot {
    sname: string
    snvid: string

    chmax: number // chap_count
    utime: number // updated_at

    stype: number
    slink: string

    stime: number = 0
    fresh: bool = false

    lasts: Wnchap[]

    free_chap: number = 40
    privi_map: [number, number, number] = [0, 1, 1]

    privi: number = 1
  }

  interface Nslist {
    _base: Chroot
    _user: Chroot
    users: Array<Chroot>
    other: Array<Chroot>
  }

  interface Wnseed {
    links: string[]
    stime: number
    _flag: number
    fresh: boolean
    //
    read_privi: number
    edit_privi: number
    gift_chaps: number
  }

  interface WnseedPage {
    _main: CV.Chroot
    users: CV.Chroot[]
    backs: CV.Chroot[]
  }
}
