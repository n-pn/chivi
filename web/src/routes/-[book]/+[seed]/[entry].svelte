<script context="module" lang="ts">
  /** @type {import('./[slug]').Load} */
  export async function load({ fetch, params, stuff }) {
    const { nvinfo } = stuff
    const { seed: sname, entry } = params

    const api_url = `/api/texts/${nvinfo.id}/${sname}/${entry}`
    const api_res = await fetch(api_url)

    if (!api_res.ok) {
      return { status: api_res.status, error: await api_res.text() }
    }

    const { infos, state } = await api_res.json()

    stuff.topbar = gen_topbar(nvinfo)
    return { props: { infos, state }, stuff }
  }

  function gen_topbar({ btitle_vi, bslug }) {
    return {
      left: [
        [btitle_vi, 'book', { href: `/-${bslug}`, kind: 'title' }],
        ['Thêm/sửa chương', 'file-plus', { href: '.', show: 'pl' }],
      ],
    }
  }
</script>

<script lang="ts">
  import { goto } from '$app/navigation'
  import { page } from '$app/stores'

  import { SIcon, Footer } from '$gui'

  export let infos: object
  export let state: string
</script>

<div>
  {JSON.stringify(infos, null, 2)}
  {state}
</div>
