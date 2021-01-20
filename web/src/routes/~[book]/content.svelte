<script context="module">
  export async function preload({ params, query }) {
    const b_slug = params.book
    const order = query.order || 'asc'

    const res = await this.fetch(`/api/nvinfos/${b_slug}`)
    if (!res.ok) this.error(res.status, await res.text())

    const { nvinfo, nvmark } = await res.json()

    const [source_main] = split_seeds(nvinfo.source, query.source)
    const source = query.source || source_main[0] || ''

    const page = +(query.page || 1)
    const ret = { nvinfo, nvmark, source, page, order }

    try {
      const params = { source: source, page, order, mode: 0 }
      const data_2 = await fetch_data(this.fetch, nvinfo.b_hash, params)
      return { ...ret, ...data_2 }
    } catch (e) {
      return { ...ret, chaps: [], total: 0, utime: 0 }
    }
  }

  const take = 30

  async function fetch_data(api, b_hash, params) {
    const page = params.page || 1
    let skip = (page - 1) * take
    if (skip < 0) skip = 0

    let url = `/api/chaps/${b_hash}/${params.source}?take=${take}&skip=${skip}`
    if (params.order) url += `&order=${params.order}`
    if (params.mode) url += `&mode=${params.mode}`

    try {
      const res = await api(url)
      const data = await res.json()
      if (res.ok) return data
      else throw data.msg
    } catch (err) {
      throw err.message
    }
  }

  function split_seeds(chseed, picked) {
    const input = Object.keys(chseed).sort((a, b) => _order(a) - _order(b))
    if (input.length < 6) return [input, []]

    let source_main = input.slice(0, 4)
    let source_hide

    if (source_main.includes(picked)) {
      source_main.push(input[4])
      source_hide = input.slice(5)
    } else if (picked) {
      source_main.push(picked)
      source_hide = input.slice(4).filter((x) => x != picked)
    }

    return [source_main, source_hide]
  }

  function _order(source) {
    switch (source) {
      case '69shu':
        return 4
      case 'paoshu8':
        return 3
      case 'shubaow':
        return 2
      case 'jx_la':
        return 1
      default:
        return 0
    }
  }

  function update_utime(nvinfo, utime) {
    if (nvinfo._utime < utime) nvinfo._utime = utime
    return nvinfo
  }
</script>

<script>
  import SvgIcon from '$atoms/SvgIcon'
  import RelTime from '$atoms/RelTime'
  import paginate_range from '$utils/paginate_range'
  // import AdBanner from '$atoms/AdBanner'

  import { u_power } from '$src/stores'

  import Common from './_common'
  import ChapList from '$melds/ChapList'

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
    const pmax = Math.floor((total - 1) / take) + 1
    if (page > pmax) page = pmax
    return pmax
  }

  $: page_list = paginate_range(page, pmax, 9)

  $: [source_main, source_hide] = split_seeds(nvinfo.source, source)
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

    const res = await fetch_data(fetch, nvinfo.b_hash, opts)

    chaps = res.chaps
    total = res.total
    utime = res.utime

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
  {#if source}
    <div class="source" bind:this={scroll_top}>
      <span class="-text"><span class="-hide">Chọn</span> nguồn:</span>
      {#each source_main as m_name}
        <a
          class="-name"
          class:_active={source === m_name}
          href={page_url(m_name, page)}
          on:click={(e) => reload(e, { source: m_name })}>{m_name}
        </a>
      {/each}

      {#if source_hide.length > 0}
        {#if show_more}
          {#each source_hide as h_name}
            <a
              class="-name"
              href={page_url(h_name, page)}
              on:click={(e) => reload(e, { source: h_name })}>{h_name}
            </a>
          {/each}
        {:else}
          <button class="-name" on:click={() => (show_more = true)}>
            <SvgIcon name="more-horizontal" />
            <span>({source_hide.length})</span>
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
          <RelTime m_time={utime * 1000} {source} />
        </span>
      </div>

      <div class="-right">
        <button
          class="m-button"
          on:click={(e) => reload(e, { page: 1, order: 'desc', mode: 2 })}>
          <SvgIcon name={_load ? 'loader' : 'rotate-ccw'} spin={_load} />
          <span class="-hide">Đổi mới</span>
        </button>

        <button
          class="m-button"
          on:click={(e) => reload(e, { order: reverse_order })}>
          <SvgIcon name={order == 'desc' ? 'arrow-down' : 'arrow-up'} />
          <span class="-hide">Sắp xếp</span>
        </button>
      </div>
    </div>

    <div class="chlist">
      <ChapList b_slug={nvinfo.b_slug} {source} {chaps} />

      {#if pmax > 1}
        <nav class="pagi">
          <a
            href={page_url(source, 1)}
            class="page m-button"
            class:_disable={page == 1}
            on:click={(e) => reload(e, { page: 1 }, true)}>
            <SvgIcon name="chevrons-left" />
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
            <SvgIcon name="chevrons-right" />
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
