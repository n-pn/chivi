<script context="module" lang="ts">
  const icons = {
    notes: 'notes',
    posts: 'user',
    links: 'link',
    crits: 'stars',
  }

  import { get } from 'svelte/store'
  import { config } from '$lib/stores'

  function make_url(url: URL, _raw = false) {
    const api_url = new URL(url)
    api_url.pathname = '/api/' + url.pathname
    if (_raw) api_url.searchParams.set('_raw', 'true')
    if (get(config).tosimp) api_url.searchParams.set('trad', 'true')

    return api_url.toString()
  }

  export async function load({ fetch, url, params }) {
    const api_url = make_url(url, true)
    const api_res = await fetch(api_url)
    const payload = await api_res.text()

    if (!api_res.ok) return { status: api_res.status, error: payload }

    const [type, name] = params.id.split('/')

    const topbar = {
      left: [
        ['Dịch nhanh', 'bolt', { href: '/qtran', show: 'ts' }],
        [`[${name}]`, icons[type], { href: name, kind: 'title' }],
      ],
      config: true,
    }

    return { props: { type, name, cvdata: payload }, stuff: { topbar } }
  }
</script>

<script lang="ts">
  import { Footer, SIcon, Crumb } from '$gui'

  import MtPage from '$gui/sects/MtPage.svelte'
  import { page } from '$app/stores'

  export let name: string

  export let cvdata = ''

  const on_change = async () => {
    const url = make_url($page.url)
    const res = await fetch(url)
    cvdata = await res.text()
  }
</script>

<svelte:head>
  <title>Dịch nhanh: {name} - Chivi</title>
</svelte:head>

<Crumb tree={[['Dịch nhanh', '/qtran']]} />

<MtPage {cvdata} {on_change} no_title={true}>
  <Footer slot="footer">
    <div class="foot">
      <button
        class="m-btn"
        data-kbd="r"
        on:click={() => window.location.reload()}>
        <SIcon name="rotate" />
        <span>Dịch lại</span>
      </button>

      <a class="m-btn _success _fill" data-kbd="n" href="/qtran">
        <span>Dịch mới</span>
      </a>
    </div>
  </Footer>
</MtPage>

<style lang="scss">
  .foot {
    @include flex($center: horz, $gap: 0.5rem);
    // justify-content: right;
  }
</style>
