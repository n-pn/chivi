<script context="module" lang="ts">
  const icons = {
    notes: 'notes',
    posts: 'user',
    links: 'link',
    crits: 'stars',
  }

  export async function load({ fetch, url, params }) {
    const [type, name] = params.id.split('/')

    const api_url = `/api/qtran/${type}/${name}${url.search}`
    const api_res = await fetch(api_url)
    const payload = await api_res.json()

    payload.props.type = type
    payload.props.name = name
    return payload
  }
</script>

<script lang="ts">
  import { topbar } from '$lib/stores'
  import { Footer, SIcon, Crumb } from '$gui'

  import CvPage from '$gui/sects/CvPage.svelte'

  export let name: string
  export let type: string

  export let dname: string
  export let d_dub: string | undefined

  export let zhtext: string[] = []
  export let cvdata = ''

  const on_change = async () => {
    const url = `/api/qtran/${type}/${name}?mode=text`
    const res = await fetch(url)
    cvdata = await res.text()
  }

  $: $topbar = {
    left: [
      ['Dịch nhanh', 'bolt', { href: '/qtran', show: 'ts' }],
      [`[${name}]`, icons[type], { href: name, kind: 'title' }],
    ],
    config: true,
  }
</script>

<svelte:head>
  <title>Dịch nhanh: {name} - Chivi</title>
</svelte:head>

<Crumb tree={[['Dịch nhanh', '/qtran']]} />

<CvPage {dname} {d_dub} {zhtext} {cvdata} {on_change} no_title={true} />

<Footer>
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

<style lang="scss">
  .foot {
    @include flex($center: horz, $gap: 0.5rem);
    // justify-content: right;
  }
</style>
