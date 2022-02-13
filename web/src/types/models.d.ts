declare namespace CV {
  interface Dboard {
    id: number
    bname: string
    bslug: string
  }

  interface Dtlist extends Paginate {
    items: any[]
  }
}
