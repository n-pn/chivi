<script context="module">
  import { remote_snames } from '$lib/constants.js'
  import { get_chseed, get_chlist } from '$api/chinfo_api.js'

  export async function load({ page: { params, query }, fetch, context }) {
    const { nvinfo } = context

    const { bhash, snames } = nvinfo
    const [sname, page] = extract_name_and_page(snames, params.seed)
    const [snvid] = nvinfo.chseed[sname] || [bhash]

    const opts = { sname, snvid, page }
    const mode = +query.get('mode')

    const [err2, chseed] = await get_chseed(fetch, bhash, opts, mode)
    if (err2) return { status: err2, error: new Error(chseed) }

    const [err3, chlist] = await get_chlist(fetch, bhash, opts)
    if (err3) return { status: err3, error: new Error(chlist) }

    return {
      props: { nvinfo, chseed, chlist, opts },
    }
  }

  function extract_name_and_page(snames, param) {
    let [name, page] = (param || '').split('/')

    if (!snames.includes(name)) name = snames[0] || 'chivi'

    page = +(page || '')
    if (page < 1) page = 1

    return [name, page]
  }

  function update_utime(nvinfo, utime) {
    if (nvinfo.update < utime) nvinfo.update = utime
    return nvinfo
  }

  function seed_choices(chseed = {}) {
    return remote_snames.filter((sname) => !chseed[sname])
  }
</script>

<script>
  import { session } from '$app/stores'

  import SIcon from '$atoms/SIcon.svelte'
  import RTime from '$atoms/RTime.svelte'
  import Chlist from '$parts/Chlist.svelte'
  import Book from '../_book.svelte'

  import paginate_range from '$utils/paginate_range'

  export let nvinfo
  export let chseed = { chaps: [], total: 0, mtime: 0 }
  export let chlist = []
  export let opts = { page: 0 }

  $: pmax = get_pmax(chseed, opts)
  $: page_list = paginate_range(opts.page, pmax, 9)

  $: [main_seeds, hide_seeds] = split_chseed(nvinfo, opts)
  let show_more = false

  let scroll_top
  let _load = false

  async function load_chseed(evt, sname, mode = 0) {
    evt.preventDefault()

    const [snvid] = nvinfo.chseed[sname] || [nvinfo.bhash]

    if (opts.sname != sname) {
      opts = { ...opts, sname, snvid }
      const url = page_url(sname, opts.page)
      window.history.replaceState({}, '', url)
    }

    _load = true

    const [err, data] = await get_chseed(fetch, nvinfo.bhash, opts, mode)
    if (err) return console.log({ err })

    chseed = data
    nvinfo = update_utime(nvinfo, chseed.utime)

    await load_chlist(opts.page, false)
    _load = false
  }

  async function load_chlist(page = 1, scroll = true) {
    if (page < 1) page = 1
    if (page > pmax) page = pmax
    opts = { ...opts, page }

    const [_err, data] = await get_chlist(fetch, nvinfo.bhash, opts)
    chlist = data

    const url = page_url(opts.sname, page)
    window.history.replaceState({}, '', url)

    if (scroll) scroll_top.scrollIntoView({ block: 'start' })
  }

  function handle_keypress(evt) {
    if ($session.privi < 1) return

    switch (evt.keyCode) {
      case 72:
        load_chlist(1)
        break

      case 76:
        load_chlist(pmax)
        break

      case 37:
      case 74:
        if (!evt.altKey) load_chlist(opts.page - 1)
        break

      case 39:
      case 75:
        if (!evt.altKey) load_chlist(opts.page + 1)
        break

      default:
        break
    }
  }

  function page_url(sname, page) {
    let url = `/~${nvinfo.bslug}/chaps/${sname}`
    if (page > 1) url += `?page=${page}`
    return url
  }

  let add_seed = false

  let new_seeds = seed_choices(nvinfo.snames)
  let new_sname = new_seeds[0]
  let new_snvid = ''

  async function add_new_seed(evt) {
    nvinfo.snames.push(new_sname)
    nvinfo.chseed[new_sname] = [new_snvid, 0, 0]
    add_seed = false

    await load_chseed(evt, new_sname, 1)
  }

  function split_chseed(nvinfo, { sname }) {
    const seeds = nvinfo.snames || ['chivi']
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

  function get_pmax({ total }, { page }) {
    const p_max = Math.floor((total - 1) / 32) + 1
    return p_max > page ? p_max : page
  }

  function is_remote_seed(sname) {
    switch (sname) {
      case 'chivi':
      case 'jx_la':
      case 'shubaow':
      case 'zxcs_me':
      case 'hotupub':
      case 'thuyvicu':
        return false

      default:
        return true
    }
  }
</script>

<svelte:window on:keydown={handle_keypress} />

<Book {nvinfo} nvtab="chaps">
  {#if main_seeds.length > 0}
    <div class="source">
      {#each main_seeds as mname}
        <a
          class="-name"
          class:_active={opts.sname === mname}
          href={page_url(mname, opts.page)}
          on:click={(e) => load_chseed(e, mname)}
          >{mname}
        </a>
      {/each}

      {#if hide_seeds.length > 0}
        {#if show_more}
          {#each hide_seeds as hname}
            <a
              class="-name"
              href={page_url(hname, opts.page)}
              on:click={(e) => load_chseed(e, hname)}
              >{hname}
            </a>
          {/each}
        {:else}
          <button class="-name" on:click={() => (show_more = true)}>
            <SIcon name="more-horizontal" />
            <span>({hide_seeds.length})</span>
          </button>
        {/if}
      {/if}

      {#if $session.privi > 2}
        <button class="-name" on:click={() => (add_seed = !add_seed)}>
          <SIcon name={add_seed ? 'minus' : 'plus'} />
        </button>
      {/if}
    </div>

    {#if add_seed}
      <div class="add-seed">
        <select class="m-input" name="new_sname" bind:value={new_sname}>
          {#each new_seeds as label}
            <option value={label}>{label}</option>
          {/each}
        </select>

        <input
          class="m-input"
          type="text"
          bind:value={new_snvid}
          required
          placeholder="Book ID" />

        <button
          class="m-button _primary"
          disabled={!new_snvid}
          on:click={add_new_seed}>
          <span class="-text">Thêm</span>
        </button>
      </div>
    {/if}

    <div class="chinfo">
      <div class="-left">
        <span class="-text">Chương mới nhất</span>
        <span class="-span">
          <RTime mtime={chseed.utime} />
        </span>
      </div>

      {#if is_remote_seed(opts.sname)}
        <button
          class="m-button"
          on:click={(e) => load_chseed(e, opts.sname, 2)}>
          <SIcon name={_load ? 'loader' : 'rotate-ccw'} spin={_load} />
          <span class="-hide">Đổi mới</span>
        </button>
      {:else if opts.sname == 'chivi'}
        <a class="m-button" href="/~{nvinfo.bslug}/+{opts.sname}">
          <SIcon name="plus" />
          <span class="-hide">Thêm chương</span>
        </a>
      {/if}
    </div>

    <div class="chlist">
      <Chlist bslug={nvinfo.bslug} sname={opts.sname} chaps={chseed.lasts} />
    </div>

    <div class="chinfo" bind:this={scroll_top}>
      <div class="-left">
        <span class="-text">Danh sách chương</span>
        <span class="-span">{chseed.total} chương</span>
      </div>
    </div>

    <div class="chlist _page">
      <Chlist bslug={nvinfo.bslug} sname={opts.sname} chaps={chlist} />

      {#if pmax > 1}
        <nav class="pagi">
          <a
            href={page_url(opts.sname, 1)}
            class="page m-button"
            class:_disable={opts.page == 1}
            on:click|preventDefault={() => load_chlist(1)}>
            <SIcon name="chevrons-left" />
          </a>

          {#each page_list as [curr, level]}
            <a
              href={page_url(opts.sname, curr)}
              class="page m-button"
              class:_primary={opts.page == curr}
              class:_disable={opts.page == curr}
              data-level={level}
              on:click|preventDefault={() => load_chlist(curr)}>
              <span>{curr}</span>
            </a>
          {/each}

          <a
            href={page_url(opts.sname, pmax)}
            class="page m-button"
            class:_disable={opts.page == pmax}
            on:click|preventDefault={() => load_chlist(pmax)}>
            <SIcon name="chevrons-right" />
          </a>
        </nav>
      {/if}
    </div>
  {:else}
    <div class="empty">Không có nội dung.</div>
  {/if}
</Book>

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
      border-radius: 0.5rem;
      padding: 0 0.75em;
      background-color: transparent;

      @include label();
      @include border();
      @include props(margin-top, 0.25rem, 0.375rem, 0.5rem);
      @include props(margin-left, 0.25rem, 0.375rem, 0.5rem);

      &._active {
        @include fgcolor(primary, 5);
        @include bdcolor(primary, 5);
      }

      @include tm-dark {
        @include bdcolor(neutral, 6);
        @include fgcolor(neutral, 3);

        &._active {
          @include fgcolor(primary, 4);
          @include bdcolor(primary, 4);
        }
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

      @include tm-dark {
        @include bgcolor(neutral, 8, 0.4);
        @include fgcolor(neutral, 2);
        &:hover {
          @include bgcolor(neutral, 8, 0.3);
        }
      }
    }

    .-text {
      padding-left: 0.5rem;
      @include label();
      @include fgcolor(neutral, 7);
      @include border($sides: left, $width: 3px, $color: primary, $shade: 5);

      @include tm-dark {
        @include fgcolor(neutral, 4);
        @include bdcolor(primary, 4);
      }
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
    padding-bottom: 0.5rem;
    // position: relative;
    // padding-bottom: 3rem;
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
    margin-top: 1rem;
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

    @include tm-dark {
      @include fgcolor(neutral, 2);
      @include bgcolor(neutral, 8, 0.4);

      &:hover {
        @include bgcolor(neutral, 8, 0.3);
      }

      &._primary {
        @include bgcolor(primary, 7);
      }
    }
  }

  .add-seed {
    display: flex;
    justify-content: center;
    margin-top: 1rem;

    > select,
    > input {
      margin-right: 0.5rem;
      max-width: 10rem;
      text-transform: uppercase;
      font-weight: 500;
      @include font-size(2);
      @include fgcolor(neutral, 6);
    }
  }
</style>
