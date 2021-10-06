<script context="module">
  export async function load({ fetch, page: { params, query } }) {
    const res = await fetch(`/api/qtran/${params.name}?${query.toString()}`)
    const props = await res.json()

    if (res.ok) return { props }
    return { status: 404, error }
  }
</script>

<script>
  import SIcon from '$atoms/SIcon.svelte'
  import Vessel from '$sects/Vessel.svelte'

  import Cvdata from '$sects/Cvdata.svelte'
  import { enabled as lookup_enabled } from '$parts/Lookup.svelte'

  export let zhtext = []
  export let cvdata = ''

  let _dirty = false
  $: if (_dirty) window.location.reload()
</script>

<svelte:head>
  <title>Dịch nhanh - Chivi</title>
</svelte:head>

<Vessel>
  <span slot="header-left" class="header-item _active">
    <SIcon name="bolt" />
    <span class="header-text">Dịch nhanh</span>
  </span>

  <svelte:fragment slot="header-right">
    <button
      class="header-item"
      class:_active={$lookup_enabled}
      on:click={() => lookup_enabled.update((x) => !x)}
      data-kbd="\">
      <SIcon name="compass" />
      <span class="header-text _show-md">Giải nghĩa</span>
    </button>
  </svelte:fragment>

  <section class="body">
    <Cvdata {zhtext} {cvdata} bind:_dirty />
  </section>

  <div slot="footer" class="foot">
    <button
      class="m-button"
      data-kbd="r"
      on:click={() => window.location.reload()}>
      <SIcon name="rotate" />
      <span>Dịch lại</span>
    </button>

    <a class="m-button _success _fill" data-kbd="n" href="/qtran">
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
