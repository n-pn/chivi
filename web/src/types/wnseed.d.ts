declare namespace CV {
  interface Chroot {
    stype: number

    sname: string
    sn_id: string

    chmax: number // chap_count
    utime: number // updated_at

    rlink: string
    rtime: number = 0
    fresh: bool = false

    privi: number = 1

    lasts: Wnchap[]

    free_chap: number = 40
    privi_map: [number, number, number] = [0, 1, 1]
  }

  interface Rdstem {
    sname: string
    sn_id: string

    chmax: number // chap_count
    utime: number // updated_at

    privi: number = 1
    gifts: number = 2
  }

  interface Nslist {
    _base: Chroot
    _user: Chroot
    users: Array<Chroot>
    other: Array<Chroot>
  }

  interface Wnstem {
    rlink: string
    rtime: number

    _flag: number
    fresh: boolean
    //
    read_privi: number
    edit_privi: number
    gift_chaps: number
  }

  interface WnstemPage {
    _main: CV.Chroot
    users: CV.Chroot[]
    backs: CV.Chroot[]
  }
}
