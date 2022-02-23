<script lang="ts">
  import { dboard_ctrl as ctrl, DtlistData } from '$lib/stores'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import DtopicList from '$gui/parts/dtopic/DtopicList.svelte'

  export let data = new DtlistData()

  let dtlist: CV.Dtlist = {
    items: [],
    pgidx: 1,
    pgmax: 1,
  }

  $: if ($ctrl.actived) load_topics(data)

  async function load_topics({ _t, b0, tl = '', pg = 1 }) {
    let api_url = `/api/topics?pg=${pg}&lm=10`
    if (tl) api_url += '&dlabel=' + tl

    if (_t == 1 && b0) api_url += '&dboard=' + b0.id
    else if (_t == 2) api_url += '&starred'

    const res = await fetch(api_url)
    const data = await res.json()

    if (res.ok) dtlist = data.props.dtlist
    else alert(data.error)
  }

  function change_tab(tab = 0) {
    ctrl.update((x) => {
      x.tab_0._t = tab
      x.tab_0.pg = 1
      x.tab_0.tl = ''
      x.tab_0.kw = ''
      return x
    })
  }
</script>

<nav class="tabs">
  <button
    class="tab"
    class:_active={data._t == 0}
    on:click={() => change_tab(0)}>
    <SIcon name="messages" />
    <span>Tất cả chủ đề</span>
  </button>

  <button
    class="tab"
    class:_active={data._t == 1}
    on:click={() => change_tab(1)}>
    <SIcon name={data.b0.id > 0 ? 'book' : 'message-2'} />

    <span>{data.b0.bname}</span>
  </button>
</nav>

<DtopicList
  dboard={data._t > 0 ? null : data.b0}
  tlabel={data.tl}
  {dtlist}
  _mode={1} />

<style lang="scss">
  .tabs {
    @include flex($gap: 0rem);
    @include border($loc: bottom);
    margin-bottom: 0.75rem;
  }

  .tab {
    display: inline-flex;
    align-items: center;

    line-height: 2rem;
    height: 2rem;

    // padding: 0 0.5rem;
    background: none;
    // max-width: 30%;
    font-weight: 500;

    flex-shrink: 1;
    @include ftsize(sm);
    @include fgcolor(tert);

    &._active {
      @include fgcolor(main);
      @include border(warning, 5, $width: 2px, $loc: bottom);
    }

    span {
      margin-left: 0.25rem;
      max-width: 8rem;
      @include clamp($width: null);
    }

    :global(svg) {
      width: 1rem;
      height: 1rem;
    }
  }
</style>
