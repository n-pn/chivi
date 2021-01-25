<script context="module">
  import { get_nvinfo, get_chseed, get_chlist } from '$utils/api_calls'

  export async function preload(req) {
    const [err1, nvinfo] = await get_nvinfo(this.fetch, req.params.book)
    if (err1) this.error(err1, nvinfo)

    const bhash = nvinfo.bhash

    const seeds = Object.keys(nvinfo.source)
    const sname = req.query.sname || seeds[0] || '_chivi'
    const snvid = nvinfo.source[sname] || bhash

    const page = +(req.query.page || 1)
    const params = { sname, snvid, page }

    const _res = { nvinfo, params }
    if (!params.snvid) return _res

    const [err2, chseed] = await get_chseed(this.fetch, params, bhash)
    if (err2) this.error(err2, chseed)

    const [err3, chlist] = await get_chlist(this.fetch, params)
    if (err3) this.error(err3, chlist)

    return { nvinfo, chseed, chlist, params }
  }

  function split_chseed({ source }, { sname }) {
    const seeds = Object.keys(source)
    if (seeds.length < 6) return [seeds, []]

    let main_seeds = seeds.slice(0, 4)
    let hide_seeds

    if (main_seeds.includes(sname)) {
      main_seeds.push(seeds[4])
      hide_seeds = seeds.slice(5)
    } else if (sname) {
      main_seeds.push(sname)
      hide_seeds = seeds.slice(4).filter((x) => x != sname)
    }

    return [main_seeds, hide_seeds]
  }

  function update_utime(nvinfo, utime) {
    if (nvinfo._utime < utime) nvinfo._utime = utime
    return nvinfo
  }

  function get_pmax({ total }, { page }) {
    const p_max = Math.floor((total - 1) / 30) + 1
    return p_max > page ? p_max : page
  }
</script>

<script>
  import SIcon from '$blocks/SIcon'
  import RTime from '$blocks/RTime'
  import paginate_range from '$utils/paginate_range'

  import { u_power } from '$src/stores'

  import Common from './_common'
  import Chlist from '$widget/Chlist'

  export let nvinfo
  export let chseed = { chaps: [], total: 0, mtime: 0 }
  export let chlist = []
  export let params = {}

  $: pmax = get_pmax(chseed, params)
  $: page_list = paginate_range(params.page, pmax, 9)

  $: [main_seeds, hide_seeds] = split_chseed(nvinfo, params)
  let show_more = false

  let scroll_top
  let _load = false

  async function load_chseed(evt, sname, mode = 0) {
    evt.preventDefault()

    const snvid = nvinfo.source[sname]

    if (params.sname != sname) {
      params = { ...params, sname, snvid }
      const url = new URL(window.location)
      url.searchParams.set('sname', sname)
      window.history.replaceState({}, '', url)
    }

    _load = true

    const [err, data] = await get_chseed(fetch, params, nvinfo.bhash, mode)
    if (err) throw data

    chseed = data
    nvinfo = update_utime(nvinfo, chseed.utime)

    await load_chlist(params.page, false)
    _load = false
  }

  async function load_chlist(page = 1, scroll = true) {
    if (page < 1) page = 1
    if (page > pmax) page = pmax
    params = { ...params, page }

    const [_err, data] = await get_chlist(fetch, params)
    chlist = data

    const url = new URL(window.location)
    url.searchParams.set('page', page)
    window.history.replaceState({}, '', url)

    if (scroll) scroll_top.scrollIntoView({ block: 'start' })
  }

  function handle_keypress(evt) {
    if ($u_power < 1) return

    switch (evt.keyCode) {
      case 72:
        load_chlist(1)
        break

      case 76:
        load_chlist(pmax)
        break

      case 37:
      case 74:
        if (!evt.altKey) load_chlist(params.page - 1)
        break

      case 39:
      case 75:
        if (!evt.altKey) load_chlist(params.page + 1)
        break

      default:
        break
    }
  }

  function page_url(sname, page) {
    let url = `/~${nvinfo.bslug}/content?sname=${sname}`
    if (page > 1) url += `&page=${page}`
    if (params.order == 'desc') url += '&order=desc'

    return url
  }
</script>

<svelte:window on:keydown={handle_keypress} />

<Common {nvinfo} atab="content">
  {#if main_seeds.length > 0}
    <div class="source">
      {#each main_seeds as mname}
        <a
          class="-name"
          class:_active={params.sname === mname}
          href={page_url(mname, params.page)}
          on:click={(e) => load_chseed(e, mname)}>{mname}
        </a>
      {/each}

      {#if hide_seeds.length > 0}
        {#if show_more}
          {#each hide_seeds as hname}
            <a
              class="-name"
              href={page_url(hname, params.page)}
              on:click={(e) => load_chseed(e, hname)}>{hname}
            </a>
          {/each}
        {:else}
          <button class="-name" on:click={() => (show_more = true)}>
            <SIcon name="more-horizontal" />
            <span>({hide_seeds.length})</span>
          </button>
        {/if}
      {/if}
    </div>

    <div class="chinfo">
      <div class="-left">
        <span class="-text">Chương mới nhất</span>
        <span class="-span">
          <RTime m_time={chseed.utime * 1000} source={params.sname} />
        </span>
      </div>

      <button
        class="m-button"
        on:click={(e) => load_chseed(e, params.sname, 2)}>
        <SIcon name={_load ? 'loader' : 'rotate-ccw'} spin={_load} />
        <span class="-hide">Đổi mới</span>
      </button>
    </div>

    <div class="chlist">
      <Chlist bslug={nvinfo.bslug} sname={params.sname} chaps={chseed.lasts} />
    </div>

    <div class="chinfo" bind:this={scroll_top}>
      <div class="-left">
        <span class="-text">Danh sách chương</span>
        <span class="-span">{chseed.total} chương</span>
      </div>
    </div>

    <div class="chlist">
      <Chlist bslug={nvinfo.bslug} sname={params.sname} chaps={chlist} />
    </div>

    {#if pmax > 1}
      <nav class="pagi">
        <a
          href={page_url(params.sname, 1)}
          class="page m-button"
          class:_disable={params.page == 1}
          on:click={() => load_chlist(1)}>
          <SIcon name="chevrons-left" />
        </a>

        {#each page_list as [curr, level]}
          <a
            href={page_url(params.sname, curr)}
            class="page m-button"
            class:_primary={params.page == curr}
            class:_disable={params.page == curr}
            data-level={level}
            on:click={() => load_chlist(curr)}>
            <span>{curr}</span>
          </a>
        {/each}

        <a
          href={page_url(params.sname, pmax)}
          class="page m-button"
          class:_disable={params.page == pmax}
          on:click={() => load_chlist(pmax)}>
          <SIcon name="chevrons-right" />
        </a>
      </nav>
    {/if}
  {:else}
    <div class="empty">Không có nội dung.</div>
  {/if}
</Common>

<style lang="scss">
  @mixin label {
    font-weight: 500;
    text-transform: uppercase;
    @include fgcolor(neutral, 6);
  }

  .source {
    @include flex($center: content);
    flex-wrap: wrap;

    @include props(font-size, 12px, 13px, 14px);
    @include props(line-height, 1.5rem, 1.75rem, 2rem);

    .-name {
      margin-top: 0.25rem;

      border-radius: 0.75rem;
      padding: 0 0.75em;
      background-color: #fff;

      @include label();
      @include border();
      @include props(margin-left, 0.25rem, 0.375rem, 0.5rem);

      &._active {
        @include fgcolor(primary, 5);
        @include bdcolor(primary, 5);
      }
    }
  }

  .-hide {
    @include props(display, none, $md: inline-block);
  }

  .chinfo {
    display: flex;
    padding: 0.75rem 0;

    .-left {
      display: flex;
      flex: 1;
      margin: 0.25rem 0;
      line-height: 1.75rem;
      transform: translateX(1px);
      @include props(font-size, 12px, 13px, 14px);
    }

    .m-button {
      margin-left: 0.25rem;
    }

    .-text {
      padding-left: 0.5rem;
      @include label();
      @include fgcolor(neutral, 7);
      @include border($sides: left, $width: 4px, $color: primary, $shade: 5);
    }

    .-span {
      font-style: italic;
      @include fgcolor(neutral, 6);

      &:before {
        display: inline-block;
        content: '·';
        text-align: center;
        @include props(width, 0.5rem, 0.75rem, 1rem);
      }
    }
  }

  .chlist {
    padding-bottom: 1rem;
  }

  .empty {
    min-height: 50vh;
    display: flex;
    align-items: center;
    justify-content: center;
    text-align: center;
    font-style: italic;
    @include font-size(4);
    @include fgcolor(neutral, 5);
  }

  .pagi {
    margin: 0.75rem 0;
    @include flex($center: content);
    @include flex-gap(0.375rem, $child: '.page');
  }

  .page {
    &._disable {
      cursor: text;
    }

    &[data-level='0'],
    &[data-level='1'] {
      display: inline-block;
    }

    &[data-level='2'] {
      @include props(display, none, $sm: inline-block);
    }

    &[data-level='3'] {
      @include props(display, none, $md: inline-block);
    }

    &[data-level='4'],
    &[data-level='5'] {
      @include props(display, none, $lg: inline-block);
    }
  }
</style>
