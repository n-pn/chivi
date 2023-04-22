<script context="module" lang="ts">
  import { dtlist_data as data, DtlistData } from '$lib/stores'

  export function make_api_url(data: DtlistData) {
    const { tab, query } = data
    let api_url = `/_db/topics?pg=${query.pg}&lm=10`

    if (query.lb) api_url += '&labels=' + query.lb
    if (query.op) api_url += '&viuser=' + query.op

    switch (tab) {
      case 'book':
      case 'show':
        api_url += '&dboard=' + data[tab].id
        break

      case 'star':
      case 'seen':
      case 'mine':
        api_url += '_self=' + tab
        break
    }

    return api_url
  }
</script>

<script lang="ts">
  import { invalidate } from '$app/navigation'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import DtopicList from '$gui/parts/dboard/DtopicList.svelte'

  let dtlist: CV.Dtlist = {
    posts: [],
    users: {},
    memos: {},
    pgidx: 1,
  }

  $: api_url = make_api_url($data)
  $: load_topics(api_url)

  async function load_topics(api_url: string) {
    const api_res = await fetch(api_url)
    if (!api_res.ok) alert(await api_res.text())
    else dtlist = await api_res.json()
  }

  function change_tab(tab: CV.DtlistType) {
    data.update((x) => {
      x.tab = tab
      x.query = { pg: 1, lb: '', kw: '', op: '' }
      return x
    })
  }

  $: [curr_icon, curr_text] = map_board($data)

  function map_board({ tab, show, book }: DtlistData) {
    switch (tab) {
      case 'show':
        return ['filter', show.bname]
      case 'book':
        return ['book', book?.bname]
      case 'seen':
        return ['history', 'Chủ đề vừa xem']
      case 'star':
        return ['star', 'Chủ đề ưa thích']
      case 'mine':
        return ['send', 'Chủ đề bạn tạo']
      default:
        return ['clear-all', 'Tất cả các chủ đề']
    }
  }

  const types: Array<CV.DtlistType> = ['book', 'show', '']
</script>

<nav class="tabs">
  <div class="curr">
    <SIcon name={curr_icon} />
    <span>{curr_text}</span>
  </div>

  <nav-right>
    {#each types as tab}
      {@const [icon, btip] = map_board({ ...$data, tab })}
      <button
        class="tab"
        class:_active={tab == $data.tab}
        on:click={() => change_tab(tab)}
        disabled={!btip}
        data-tip={btip}
        data-tip-loc="bottom"
        data-tip-pos="right">
        <SIcon name={icon} />
      </button>
    {/each}
  </nav-right>
</nav>

<section>
  <DtopicList
    dboard={$data[$data.tab]}
    tlabel={$data.query.lb}
    {dtlist}
    _mode={1} />
</section>

<style lang="scss">
  section {
    flex: 1;
    overflow-y: auto;
    @include scroll();
    padding: 0.75rem;
  }

  .tabs {
    @include flex();
    @include border($loc: bottom);
    margin: 0 0.75rem;
    // padding-top: 0.5rem;
    line-height: 2rem;
    height: 2rem;
  }

  .curr {
    @include flex-cy;
    flex-shrink: 1;
    // flex: 1;
    @include fgcolor(main);
    :global(svg) {
      @include fgcolor(warning, 5);
      width: 1.125rem;
      height: 1.125rem;
      margin-right: 0.25rem;
    }

    > span {
      @include clamp($width: null);
      @include bps(max-width, 30vw, 40vw, $pl: 12rem);
    }
  }

  nav-right {
    @include flex($gap: 0rem);
    // flex-shrink: 0;
    margin-left: auto;
  }

  .tab {
    @include flex-ca;
    margin: 0;
    padding: 0;
    // padding: 0 0.5rem;
    background: none;
    width: 2rem;
    height: 2rem;
    // max-width: 30%;
    font-weight: 500;

    @include ftsize(sm);
    @include fgcolor(tert);

    &._active {
      @include fgcolor(main);
      @include border(warning, 5, $width: 2px, $loc: bottom);
    }

    &:disabled {
      @include fgcolor(mute);
    }

    :global(svg) {
      width: 1rem;
      height: 1rem;
    }
  }
</style>
