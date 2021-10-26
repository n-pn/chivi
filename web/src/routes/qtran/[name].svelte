<script context="module">
  export async function load({ fetch, page: { params, query } }) {
    const qname = params.name

    const res = await fetch(`/api/qtran/${qname}?${query.toString()}`)
    const props = await res.json()

    if (res.ok) return { props: { ...props, qname } }
    return { status: 404, error }
  }
</script>

<script>
  import SIcon from '$atoms/SIcon.svelte'
  import Header from '$sects/Header.svelte'
  import Vessel from '$sects/Vessel.svelte'

  import Cvdata from '$sects/Cvdata.svelte'
  import { enabled as lookup_enabled } from '$parts/Lookup.svelte'

  export let zhtext = []
  export let cvdata = ''
  export let qname

  let _dirty = false
  $: if (_dirty) window.location.reload()
</script>

<svelte:head>
  <title>Dịch nhanh - Chivi</title>
</svelte:head>

<Header>
  <svelte:fragment slot="left">
    <a href="/qtran" class="header-item">
      <SIcon name="bolt" />
      <span class="header-text">Dịch nhanh</span>
    </a>

    <span class="header-item _active _title">
      <span class="header-text">{qname}</span>
    </span>
  </svelte:fragment>

  <svelte:fragment slot="right">
    <button
      class="header-item"
      class:_active={$lookup_enabled}
      on:click={() => lookup_enabled.update((x) => !x)}
      data-kbd="\">
      <SIcon name="compass" />
      <span class="header-text _show-md">Giải nghĩa</span>
    </button>
  </svelte:fragment>
</Header>

<Vessel>
  <section class="body">
    <Cvdata {zhtext} {cvdata} bind:_dirty />
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
