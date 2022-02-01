<script context="module">
  import { data as appbar } from '$sects/Appbar.svelte'

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
    const props = await api_res.json()

    if (!api_res.ok) return { status: 404, error }

    appbar.set({
      left: [
        ['Dịch nhanh', 'bolt', '/qtran', null, '_show-sm'],
        [`[${name}]`, icons[type], null, '_title'],
      ],
      cvmtl: true,
    })

    return { props: { ...props, type, name } }
  }
</script>

<script>
  import SIcon from '$atoms/SIcon.svelte'
  import Footer from '$sects/Footer.svelte'
  import CvPage from '$sects/CvPage.svelte'

  export let name
  export let type

  export let dname
  export let d_dub

  export let zhtext = []
  export let cvdata = ''

  const on_change = async () => {
    const url = `/api/qtran/${type}/${name}?mode=text`
    const res = await fetch(url)
    cvdata = await res.text()
  }
</script>

<svelte:head>
  <title>Dịch nhanh: {name} - Chivi</title>
</svelte:head>

<section class="body">
  <CvPage {dname} {d_dub} {zhtext} {cvdata} {on_change}>
    <svete:fragment slot="header">
      <nav class="bread">
        <a href="/qtran" class="crumb _link">Dịch nhanh</a>
        <span>/</span>
        <span class="crumb _text">[{type}]</span>

        <span>/</span>
        <span class="crumb _text">[{name}]</span>
      </nav>
    </svete:fragment>
  </CvPage>
</section>

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
  .body {
    margin-top: 1rem;
  }

  .foot {
    @include flex($center: horz, $gap: 0.5rem);
    // justify-content: right;
  }
</style>
