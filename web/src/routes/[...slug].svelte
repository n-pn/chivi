<script context="module">
  export async function load({ fetch, page: { params, query } }) {
    const { slug } = params

    if (slug.startsWith('~')) {
      return await old_book(fetch, slug.substr(1))
    } else if (slug == 'translate') {
      return { status: 301, redirect: '/qtran' }
    } else {
      return { status: 404, error: new Error(`${slug} not found!`) }
    }
  }

  async function old_book(fetch, slug) {
    const [bname, ...remain] = slug.split('/')
    const res = await fetch(`/api/books/find/${bname}`)
    const bslug = await res.text()
    return { status: 301, redirect: `/-${[bslug, ...remain].join('/')}` }
  }
</script>
