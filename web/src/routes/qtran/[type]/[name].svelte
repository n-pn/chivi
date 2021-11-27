<script context="module">
  export async function load({ fetch, page: { params, query } }) {
    const { type, name } = params

    const url = `/api/qtran/${type}/${name}?${query.toString()}`
    const res = await fetch(url)
    const props = await res.json()

    if (res.ok) return { props: { ...props, type, name } }
    return { status: 404, error }
  }

  const icons = {
    notes: 'notes',
    posts: 'user',
    links: 'link',
    crits: 'stars',
  }
</script>

<script>
  import SIcon from '$atoms/SIcon.svelte'
  import Appbar from '$sects/Appbar.svelte'
  import Vessel from '$sects/Vessel.svelte'

  import Cvdata from '$sects/Cvdata.svelte'

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
  <title>Dịch nhanh - Chivi</title>
</svelte:head>

<Appbar ptype="cvmtl">
  <svelte:fragment slot="left">
    <a href="/qtran" class="header-item">
      <SIcon name="bolt" />
      <span class="header-text">Dịch nhanh</span>
    </a>

    <span class="header-item _active _title">
      <SIcon name={icons[type]} />
      <span class="header-text">[{name}]</span>
    </span>
  </svelte:fragment>
</Appbar>

<Vessel>
  <section class="body">
    <Cvdata {dname} {d_dub} {zhtext} {cvdata} {on_change}>
      <svete:fragment slot="header">
        <nav class="bread">
          <a href="/qtran" class="crumb _link">Dịch nhanh</a>
          <span>/</span>
          <span class="crumb _text">[{type}]</span>

          <span>/</span>
          <span class="crumb _text">[{name}]</span>
        </nav>
      </svete:fragment>
    </Cvdata>
  </section>

  <div slot="footer" class="foot">
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
</Vessel>

<style lang="scss">
  .body {
    margin-top: 1rem;
  }

  .foot {
    @include flex($center: horz, $gap: 0.5rem);
    // justify-content: right;
  }
</style>
