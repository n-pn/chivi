<script context="module">
  export async function preload({ params, query }) {
    const bslug = params.book
    const order = query.order || 'asc'

    const res = await this.fetch(`/api/nvinfos/${bslug}`)
    if (!res.ok) this.error(res.status, await res.text())

    const { nvinfo, nvmark } = await res.json()

    const [main_seeds] = split_seeds(nvinfo.chseed, query.seed)
    const seed = query.seed || main_seeds[0] || ''
    const page = +(query.page || 1)

    const opts = { seed, page, order, mode: 0 }
    const result = { nvinfo, nvmark, seed, page, order }

    try {
      const res2 = await fetch_data(this.fetch, nvinfo.bhash, opts)

      return { ...result, ...res2 }
    } catch (e) {
      return { ...result, chaps: [], total: 0, mftime: 0 }
    }
  }

  const limit = 30

  async function fetch_data(api, bhash, opts) {
    const page = opts.page || 1
    let offset = (page - 1) * limit
    if (offset < 0) offset = 0

    let url = `/api/chaps/${bhash}/${opts.seed}?limit=${limit}&offset=${offset}`
    if (opts.order) url += `&order=${opts.order}`
    if (opts.mode) url += `&mode=${opts.mode}`

    try {
      const res = await api(url)
      const data = await res.json()
      if (res.ok) return data
      else throw data.msg
    } catch (err) {
      throw err.message
    }
  }

  function split_seeds(chseed, curr) {
    const input = Object.keys(chseed)
    const seeds = input.sort((a, b) => seed_order(a) - seed_order(b))

    if (seeds.length < 6) return [seeds, []]

    const main_seeds = seeds.slice(0, 4)
    let extra_seeds

    if (main_seeds.includes(curr)) {
      main_seeds.push(seeds[4])
      extra_seeds = seeds.slice(5)
    } else if (curr) {
      main_seeds.push(curr)
      extra_seeds = seeds.slice(4).filter((x) => x != curr)
    }

    return [main_seeds, extra_seeds]
  }

  function seed_order(seed) {
    switch (seed) {
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

  function update_mftime(nvinfo, mftime) {
    if (nvinfo.update_tz < mftime) nvinfo.update_tz = mftime
    return nvinfo
  }
</script>

<script>
  import SvgIcon from '$atoms/SvgIcon'
  import RelTime from '$atoms/RelTime'
  import paginate_range from '$utils/paginate_range'
  // import AdBanner from '$atoms/AdBanner'

  import { self_power } from '$src/stores'

  import Common from './_common'
  import ChapList from '$melds/ChapList'

  export let nvinfo
  export let nvmark = ''

  export let seed
  export let page = 1
  export let order = 'asc'

  export let chaps = []
  export let total = 0
  export let mftime = 0

  $: pmax = fix_pmax(total)
  $: reverse_order = order == 'desc' ? 'asc' : 'desc'

  function fix_pmax(total) {
    const pmax = Math.floor((total - 1) / limit) + 1
    if (page > pmax) page = pmax
    return pmax
  }

  $: page_list = paginate_range(page, pmax, 7)

  $: [main_seeds, extra_seeds] = split_seeds(nvinfo.chseed, seed)
  let show_extra = false

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

    if (opts.seed) {
      if (seed != opts.seed) {
        seed = opts.seed
        url.searchParams.set('seed', seed)
      }
    } else {
      opts.seed = seed
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
      if (opts.mode > $self_power) opts.mode = $self_power
    } else {
      opts.mode = 0
    }

    _load = true

    const res = await fetch_data(fetch, nvinfo.bhash, opts)
    chaps = res.chaps
    total = res.total

    nvinfo = update_mftime(nvinfo, res.mftime)

    if (scroll) scroll_top.scrollIntoView({ block: 'start' })
    window.history.replaceState({}, '', url)

    _load = false
  }

  function handleKeypress(evt) {
    if ($self_power < 1) return

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

  function page_url(seed, page) {
    let url = `/~${nvinfo.bslug}/content?seed=${seed}`
    if (page > 1) url += `&page=${page}`
    if (order == 'desc') url += '&order=desc'
    return url
  }
</script>

<svelte:window on:keydown={handleKeypress} />

<Common {...nvinfo} {nvmark} atab="content">
  {#if seed}
    <div class="chseed" bind:this={scroll_top}>
      <span class="-text"><span class="-hide">Chọn</span> nguồn:</span>
      {#each main_seeds as name}
        <a
          class="-seed"
          class:_active={seed === name}
          href={page_url(name, page)}
          on:click={(e) => reload(e, { seed: name })}>{name}
        </a>
      {/each}

      {#if extra_seeds.length > 0}
        {#if show_extra}
          {#each extra_seeds as name}
            <a
              class="-seed"
              href={page_url(name, page)}
              on:click={(e) => reload(e, { seed: name })}>{name}
            </a>
          {/each}
        {:else}
          <button class="-seed" on:click={() => (show_extra = true)}>
            <SvgIcon name="more-horizontal" />
            <span>({extra_seeds.length})</span>
          </button>
        {/if}
      {/if}
    </div>

    <div class="chinfo">
      <div class="-left">
        <span class="-text -hide">Nguồn:</span>
        <span class="-seed">{seed}</span>
        <span class="-size">{total} chương</span>
        <span class="-time">
          <span class="-hide">Cập nhật:</span>
          <RelTime time={mftime * 1000} {seed} />
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
      <ChapList bslug={nvinfo.bslug} sname={seed} {chaps} />

      {#if pmax > 1}
        <nav class="pagi">
          <a
            href={page_url(seed, 1)}
            class="page m-button"
            class:_disable={page == 1}
            on:click={(e) => reload(e, { page: 1 }, true)}>
            <SvgIcon name="chevrons-left" />
          </a>

          <a
            href={page_url(seed, page - 1)}
            class="page m-button"
            class:_disable={page < 2}
            on:click={(e) => reload(e, { page: page - 1 }, true)}>
            <SvgIcon name="chevron-left" />
          </a>

          {#each page_list as [curr, level]}
            <a
              href={page_url(seed, curr)}
              class="page m-button"
              class:_primary={page == curr}
              class:_disable={page == curr}
              data-level={level}
              on:click={(e) => reload(e, { page: curr }, true)}>
              <span>{curr}</span>
            </a>
          {/each}

          <a
            href={page_url(seed, page + 1)}
            class="page m-button"
            class:_disable={page + 1 >= pmax}
            on:click={(e) => reload(e, { page: page + 1 }, true)}>
            <SvgIcon name="chevron-right" />
          </a>

          <a
            href={page_url(seed, pmax)}
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

  .chseed {
    @include flex();
    flex-wrap: wrap;

    .-text,
    .-seed {
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

    .-seed {
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
    .-seed {
      @include label();
    }

    .-text {
      margin-right: 0.5rem;
    }

    .-seed {
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

    &[data-level='0'] {
      display: inline-block;
    }

    &[data-level='1'] {
      @include props(display, none, $sm: inline-block);
    }

    &[data-level='2'] {
      @include props(display, none, $md: inline-block);
    }

    &[data-level='3'],
    &[data-level='4'] {
      @include props(display, none, $lg: inline-block);
    }
  }
</style>
