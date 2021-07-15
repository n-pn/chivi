<script context="module">
  import { remote_snames } from '$lib/constants.js'
  import { get_chseed, get_chlist } from '$api/chinfo_api.js'

  export async function load({ page: { params, query }, fetch, context }) {
    const { nvinfo } = context

    const { bhash, snames } = nvinfo
    const sname = extract_sname(snames, params.seed)
    const page = +query.get('page') || 1

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

  function extract_sname(snames, param) {
    return snames.includes(param) ? param : snames[0] || 'chivi'
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
  import { session, navigating, page } from '$app/stores'

  import SIcon from '$atoms/SIcon.svelte'
  import RTime from '$atoms/RTime.svelte'
  import Chlist from '$parts/Chlist.svelte'
  import Book from '../_book.svelte'

  import Mpager, { Pager, navigate } from '$molds/Mpager.svelte'
  import { writable } from 'svelte/store'

  let pagers = {}
  $: pager = get_pager(opts.sname)

  let scroll_into = writable(null)

  function get_pager(sname) {
    return (pagers[sname] ||= new Pager(`/~${nvinfo.bslug}/chaps/${sname}`, {
      page: opts.page,
    }))
  }

  export let nvinfo
  export let chseed = { chaps: [], total: 0, mtime: 0 }
  export let chlist = []
  export let opts = { page: 1 }

  $: pmax = get_pmax(chseed, opts)

  $: [main_seeds, hide_seeds] = split_chseed(nvinfo, opts)
  let show_more = false

  async function load_chseed(evt, sname, mode = 0) {
    evt.preventDefault()

    const [snvid] = nvinfo.chseed[sname] || [nvinfo.bhash]

    if (opts.sname != sname) {
      opts = { ...opts, sname, snvid }
      const url = get_pager(sname).url({ page: opts.page })
      window.history.replaceState({}, '', url)
    }

    const [err, data] = await get_chseed(fetch, nvinfo.bhash, opts, mode)
    if (err) return console.log({ err })

    chseed = data
    nvinfo = update_utime(nvinfo, chseed.utime)

    await load_chlist(opts.page, false)
  }

  async function load_chlist(page = 1, scroll = true) {
    if (page < 1) page = 1
    if (page > pmax) page = pmax
    opts = { ...opts, page }

    const [_err, data] = await get_chlist(fetch, nvinfo.bhash, opts)
    chlist = data

    const url = pager.url({ page: opts.page })
    window.history.replaceState({}, '', url)
    if (scroll) $scroll_into?.scrollIntoView({ block: 'start' })
  }

  const _navi = { replace: true, scrollto: '#chlist' }

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

<Book {nvinfo} nvtab="chaps">
  <div class="source">
    {#each main_seeds as mname}
      <a
        class="-name"
        class:_active={opts.sname === mname}
        href={get_pager(mname).url({ page: opts.page })}
        use:navigate={_navi}
        >{mname}
      </a>
    {/each}

    {#if hide_seeds.length > 0}
      {#if show_more}
        {#each hide_seeds as hname}
          <a
            class="-name"
            href={get_pager(hname).url({ page: opts.page })}
            use:navigate={_navi}
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

  <div id="chlist" class="chinfo">
    <div class="-left">
      <span class="-text">{opts.sname}</span>
      <span class="-span">
        <RTime mtime={chseed.utime} />
      </span>

      <span class="-span">{chseed.total} chương</span>
    </div>

    {#if opts.sname == 'chivi'}
      <a class="m-button" href="/~{nvinfo.bslug}/+{opts.sname}">
        <SIcon name="plus" />
        <span class="-hide">Thêm chương</span>
      </a>
    {:else}
      <a
        class="m-button"
        href={pager.url({ page: opts.page, mode: is_remote_seed ? 2 : 1 })}
        use:navigate={_navi}>
        {#if $navigating}
          <SIcon name="loader" spin={true} />
        {:else}
          <SIcon name="rotate-ccw" />
        {/if}
        <span class="-hide">Đổi mới</span>
      </a>
    {/if}
  </div>

  <div class="chlist">
    {#if chseed.lasts.length > 0}
      <Chlist bslug={nvinfo.bslug} sname={opts.sname} chaps={chseed.lasts} />
      <div class="-sep" />
      <Chlist bslug={nvinfo.bslug} sname={opts.sname} chaps={chlist} />

      <footer class="foot">
        <Mpager {pager} pgidx={opts.page} pgmax={pmax} {_navi} />
      </footer>
    {:else}
      <p class="empty">Không có nội dung :(</p>
    {/if}
  </div>
</Book>

<style lang="scss">
  @mixin label {
    font-weight: 500;
    text-transform: uppercase;
    @include fgcolor(neutral, 6);
  }

  .source {
    @include flex($center: horz);
    flex-wrap: wrap;

    @include fluid(font-size, 12px, 13px, 14px);
    @include fluid(line-height, 1.5rem, 1.75rem, 2rem);

    .-name {
      border-radius: 0.5rem;
      padding: 0 0.75em;
      background-color: transparent;

      @include label();
      @include border();
      @include fluid(margin-top, 0.25rem, 0.375rem, 0.5rem);
      @include fluid(margin-left, 0.25rem, 0.375rem, 0.5rem);

      &._active {
        @include fgcolor(primary, 5);
        @include bdcolor(primary, 5);
      }

      @include tm-dark {
        @include bdcolor(gray, 6);
        @include fgcolor(neutral, 3);

        &._active {
          @include fgcolor(primary, 4);
          @include bdcolor(primary, 4);
        }
      }
    }
  }

  .-hide {
    @include fluid(display, none, $md: inline-block);
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
      @include fluid(font-size, 12px, 13px, 14px);
    }

    .m-button {
      margin-left: 0.25rem;

      @include tm-dark {
        @include bgcolor(neutral, 8);
        @include fgcolor(neutral, 2);
        &:hover {
          @include bgcolor(neutral, 8);
        }
      }
    }

    .-text {
      padding-left: 0.5rem;
      @include label();
      @include fgcolor(tert);
      @include border(primary, 5, $width: 3px, $sides: left);
    }

    .-span {
      font-style: italic;
      @include fgcolor(neutral, 4);

      &:before {
        display: inline-block;
        content: '·';
        text-align: center;
        @include fluid(width, 0.5rem, 0.75rem, 1rem);
      }
    }
  }

  .chlist {
    > .-sep {
      width: 50%;
      margin: var(--gutter-small) auto;
      @include border(--bd-main, $sides: bottom);
    }
  }

  .empty {
    min-height: 30vh;
    display: flex;
    align-items: center;
    justify-content: center;
    text-align: center;
    font-style: italic;
    @include ftsize(lg);
    @include fgcolor(neutral, 5);
  }

  .foot {
    margin-top: 1rem;
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
      @include ftsize(sm);
      @include fgcolor(neutral, 6);
    }
  }
</style>
