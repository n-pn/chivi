declare namespace CV {
  interface Unotif {
    content: string
    link_to: string

    reached_at?: number
    created_at?: number
  }

  interface UnotifPage extends Paginate {
    notifs: Unotif[]
  }
}
