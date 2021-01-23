<script context="module">
  import { get_chlist } from '$utils/api_calls'

  export async function preload({ params, query }) {
    const b_slug = params.book
    const order = query.order || 'asc'

    const res = await this.fetch(`/api/nvinfos/${b_slug}`)
    if (!res.ok) this.error(res.status, await res.text())

    const { nvinfo, nvmark } = await res.json()

    const chseed = Object.keys(nvinfo.source)
    const source = query.source || chseed[0] || '_chivi'

    const page = +(query.page || 1)
    const ret = { nvinfo, nvmark, source, page, order }

    try {
      const params = { source, page, order, mode: 0 }
      const data_2 = await get_chlist(this.fetch, nvinfo.b_hash, params)
      return { ...ret, ...data_2 }
    } catch (e) {
      return { ...ret, chaps: [], total: 0, utime: 0 }
    }
  }

  function split_chseed(nvinfo, picked) {
    const input = Object.keys(nvinfo.source)
    if (input.length < 6) return [input, []]

    let main_seeds = input.slice(0, 4)
    let hide_seeds

    if (main_seeds.includes(picked)) {
      main_seeds.push(input[4])
      hide_seeds = input.slice(5)
    } else if (picked) {
      main_seeds.push(picked)
      hide_seeds = input.slice(4).filter((x) => x != picked)
    }

    return [main_seeds, hide_seeds]
  }

  function update_utime(nvinfo, utime) {
    if (nvinfo._utime < utime) nvinfo._utime = utime
    return nvinfo
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
  export let nvmark = ''
  export let source

  export let page = 1
  export let order = 'asc'

  export let utime = 0
  export let total = 0
  export let chaps = []

  $: pmax = fix_pmax(total)
  $: reverse_order = order == 'desc' ? 'asc' : 'desc'

  function fix_pmax(total) {
    const pmax = Math.floor((total - 1) / 30) + 1
    if (page > pmax) page = pmax
    return pmax
  }

  $: page_list = paginate_range(page, pmax, 9)

  $: [main_seeds, hide_seeds] = split_chseed(nvinfo, source)
  let show_more = false

  let scroll_top

  let _load = false

  async function reload(evt, opts = {}, scroll = false) {
    evt.preventDefault()
    const url = new URL(window.location)

    if (opts.page) {
      let new_page = opts.page
      if (new_page < 1) new_page = 1
      if (new_page > pmax) new_page = pmax

      if (page != new_page) {
        page = new_page
        url.searchParams.set('page', page)
      }
    } else {
      opts.page = page
    }

    if (opts.source) {
      if (source != opts.source) {
        source = opts.source
        url.searchParams.set('source', source)
      }
    } else {
      opts.source = source
    }

    if (opts.order) {
      if (order != opts.order) {
        order = opts.order
        url.searchParams.set('order', opts.order)
      }
    } else {
      opts.order = order
    }

    if (opts.mode) {
      if (opts.mode > $u_power) opts.mode = $u_power
    } else {
      opts.mode = 0
    }

    _load = true

    const res = await get_chlist(fetch, nvinfo.b_hash, opts)

    chaps = res.chaps
    total = res.total
    utime = res.utime

    if (res.chseed) nvinfo.source = res.chseed
    nvinfo = update_utime(nvinfo, res.utime)

    if (scroll) scroll_top.scrollIntoView({ block: 'start' })
    window.history.replaceState({}, '', url)

    _load = false
  }

  function handle_keypress(evt) {
    if ($u_power < 1) return

    switch (evt.keyCode) {
      case 72:
        reload(evt, { page: 1 }, true)
        break

      case 76:
        reload(evt, { page: pmax }, true)
        break

      case 37:
      case 74:
        if (!evt.altKey) reload(evt, { page: page - 1 }, true)
        break

      case 39:
      case 75:
        if (!evt.altKey) reload(evt, { page: page + 1 }, true)
        break

      default:
        break
    }
  }

  function page_url(source, page) {
    let url = `/~${nvinfo.b_slug}/content?source=${source}`
    if (page > 1) url += `&page=${page}`
    if (order == 'desc') url += '&order=desc'
    return url
  }
</script>

<svelte:window on:keydown={handle_keypress} />

<Common {nvinfo} {nvmark} atab="content">
  {#if main_seeds.length > 0}
    <div class="source" bind:this={scroll_top}>
      <span class="-text"><span class="-hide">Chọn</span> nguồn:</span>
      {#each main_seeds as m_name}
        <a
          class="-name"
          class:_active={source === m_name}
          href={page_url(m_name, page)}
          on:click={(e) => reload(e, { source: m_name })}>{m_name}
        </a>
      {/each}

      {#if hide_seeds.length > 0}
        {#if show_more}
          {#each hide_seeds as h_name}
            <a
              class="-name"
              href={page_url(h_name, page)}
              on:click={(e) => reload(e, { source: h_name })}>{h_name}
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
        <span class="-text -hide">Nguồn:</span>
        <span class="-name">{source}</span>
        <span class="-size">{total} chương</span>
        <span class="-time">
          <span class="-hide">Cập nhật:</span>
          <RTime m_time={utime * 1000} {source} />
        </span>
      </div>

      <div class="-right">
        <button
          class="m-button"
          on:click={(e) => reload(e, { page: 1, order: 'desc', mode: 2 })}>
          <SIcon name={_load ? 'loader' : 'rotate-ccw'} spin={_load} />
          <span class="-hide">Đổi mới</span>
        </button>

        <button
          class="m-button"
          on:click={(e) => reload(e, { order: reverse_order })}>
          <SIcon name={order == 'desc' ? 'arrow-down' : 'arrow-up'} />
          <span class="-hide">Sắp xếp</span>
        </button>
      </div>
    </div>

    <div class="chlist">
      <Chlist b_slug={nvinfo.b_slug} {source} {chaps} />

      {#if pmax > 1}
        <nav class="pagi">
          <a
            href={page_url(source, 1)}
            class="page m-button"
            class:_disable={page == 1}
            on:click={(e) => reload(e, { page: 1 }, true)}>
            <SIcon name="chevrons-left" />
          </a>

          {#each page_list as [curr, level]}
            <a
              href={page_url(source, curr)}
              class="page m-button"
              class:_primary={page == curr}
              class:_disable={page == curr}
              data-level={level}
              on:click={(e) => reload(e, { page: curr }, true)}>
              <span>{curr}</span>
            </a>
          {/each}

          <a
            href={page_url(source, pmax)}
            class="page m-button"
            class:_disable={page == pmax}
            on:click={(e) => reload(e, { page: pmax }, true)}>
            <SIcon name="chevrons-right" />
          </a>
        </nav>
      {/if}
    </div>
  {:else}
    <div class="empty">Không có nội dung.</div>
  {/if}
</Common>

<style lang="scss">
  @mixin label {
    text-transform: uppercase;
    font-weight: 500;
    @include fgcolor(neutral, 6);
  }

  .source {
    @include flex();
    flex-wrap: wrap;

    .-text,
    .-name {
      margin-top: 0.25rem;

      @include label();
      @include props(font-size, 12px, 13px, 14px);
      @include props(line-height, 1.5rem, 1.75rem, 2rem);
    }

    .-text {
      // margin-right: 0.5rem;
      padding-top: 1px;
      // margin-top: 0.25rem;
    }

    .-name {
      // float: left;
      @include props(margin-left, 0.25rem, 0.375rem, 0.5rem);

      @include border();
      border-radius: 1rem;
      padding: 0 0.75rem;
      background-color: #fff;

      &._active {
        border-color: color(primary, 5);
        color: color(primary, 5);
      }
    }
  }

  .-hide {
    @include props(display, none, $md: inline-block);
  }

  .chinfo {
    margin: 0.5rem 0 0.75rem;
    display: flex;

    .-left {
      display: flex;
      margin-right: 0.5rem;
    }

    .-right {
      margin-left: auto;
      @include flex();
      @include flex-gap($gap: 0.5rem, $child: ':global(*)');
    }

    line-height: 2.25rem;

    @include props(font-size, 12px, 13px, 14px, 15px);

    .-text,
    .-name {
      @include label();
    }

    .-text {
      margin-right: 0.5rem;
    }

    .-name {
      @include fgcolor(neutral, 7);
    }

    .-time {
      font-style: italic;
    }

    .-size,
    .-time {
      @include fgcolor(neutral, 6);
      &:before {
        display: inline-block;
        content: '·';
        text-align: center;
        @include props(width, 0.5rem, 0.75rem, 1rem);
      }
    }
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
    margin-top: 0.75rem;
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
