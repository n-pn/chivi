<script context="module">
  import { remote_snames } from '$lib/constants.js'

  import { api_call } from '$api/_api_call'

  export async function load({ page: { params, query }, fetch, context }) {
    const { nvinfo } = context

    const { snames } = nvinfo
    const sname = extract_sname(snames, params.seed)

    const page = +query.get('page') || 1
    const mode = +query.get('mode') || 0

    const url = `chaps/${nvinfo.id}/${sname}?page=${page}&mode=${mode}`

    const [status, chinfo] = await api_call(fetch, url)
    if (status) return { status, error: new Error(chinfo) }

    if (chinfo.utime > nvinfo.update) nvinfo.update = chinfo.utime
    return { props: { nvinfo, chinfo } }
  }

  function extract_sname(snames, param) {
    return snames.includes(param) ? param : snames[1] || 'chivi'
  }

  function seed_choices(chinfo = {}) {
    return remote_snames.filter((sname) => !chinfo[sname])
  }
</script>

<script>
  import { session, navigating } from '$app/stores'

  import SIcon from '$atoms/SIcon.svelte'
  import RTime from '$atoms/RTime.svelte'
  import Chlist from '$parts/Chlist.svelte'
  import Book from '../_book.svelte'

  import Mpager, { Pager, navigate } from '$molds/Mpager.svelte'

  let pagers = {}
  $: pager = get_pager(chinfo.sname)

  function get_pager(sname) {
    return (pagers[sname] ||= new Pager(`/-${nvinfo.bslug}/chaps/${sname}`, {
      page: chinfo.pgidx,
    }))
  }

  export let nvinfo
  export let chinfo = {}

  $: [main_seeds, hide_seeds] = split_chinfo(nvinfo, chinfo.sname)
  let show_more = false

  const _navi = { replace: true, scrollto: '#chlist' }

  let add_zhbook = false

  let new_seeds = seed_choices(nvinfo.snames)
  let new_sname = new_seeds[0]
  let new_snvid = ''

  async function make_zhbook() {
    nvinfo.snames.push(new_sname)
    nvinfo.chinfo[new_sname] = new_snvid
    add_zhbook = false

    // TODO: create new zhbook on server
  }

  function split_chinfo(nvinfo, sname) {
    const input = nvinfo.snames.filter((x) => x != 'chivi')
    const bound = 3

    let main_seeds = input.slice(0, bound)
    let hide_seeds = []

    if (main_seeds.includes(sname)) {
      const leftover = input[bound]
      if (leftover) main_seeds.push(leftover)
      hide_seeds = input.slice(bound + 1)
    } else if (sname) {
      main_seeds.push(sname)
      hide_seeds = input.slice(bound).filter((x) => x != sname)
    }

    if (sname != 'chivi') main_seeds.push('chivi')
    return [main_seeds, hide_seeds]
  }
</script>

<Book {nvinfo} nvtab="chaps">
  <div class="source">
    {#each main_seeds as mname}
      <a
        class="-name"
        class:_active={chinfo.sname === mname}
        href={get_pager(mname).url({ page: chinfo.pgidx })}
        use:navigate={_navi}
        >{mname}
      </a>
    {/each}

    {#if hide_seeds.length > 0}
      {#if show_more}
        {#each hide_seeds as hname}
          <a
            class="-name"
            href={get_pager(hname).url({ page: chinfo.pgidx })}
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
      <button class="-name" on:click={() => (add_zhbook = !add_zhbook)}>
        <SIcon name={add_zhbook ? 'minus' : 'plus'} />
      </button>
    {/if}
  </div>

  {#if add_zhbook}
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
        on:click={make_zhbook}>
        <span class="-text">Thêm</span>
      </button>
    </div>
  {/if}

  <div id="chlist" class="chinfo">
    <div class="-left">
      <span class="-text">{chinfo.sname}</span>
      <span class="-span">{chinfo.total} chương</span>
      <span class="-span"><RTime mtime={chinfo.utime} /></span>
    </div>

    {#if chinfo.sname == 'chivi'}
      <a
        class="m-button"
        href="/-{nvinfo.bslug}/+{chinfo.sname}?chidx={chinfo.total + 1}">
        <SIcon name="plus" />
        <span class="-hide">Thêm chương</span>
      </a>
    {:else}
      <a
        class="m-button"
        href={chinfo.wlink}
        target="_blank"
        rel="noopener noreferer">
        <SIcon name="external-link" />
        <span class="-hide">Nguồn</span>
      </a>
      <a
        class="m-button"
        class:_disable={!chinfo.crawl}
        href={pager.url({ page: chinfo.pgidx, mode: chinfo.crawl ? 2 : 1 })}
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
    {#if chinfo.lasts.length > 0}
      <Chlist bslug={nvinfo.bslug} sname={chinfo.sname} chaps={chinfo.lasts} />
      <div class="-sep" />
      <Chlist bslug={nvinfo.bslug} sname={chinfo.sname} chaps={chinfo.chaps} />

      <footer class="foot">
        <Mpager {pager} pgidx={chinfo.pgidx} pgmax={chinfo.pgmax} {_navi} />
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
    @include fgcolor(tert);
  }

  .source {
    @include flex($center: horz, $wrap: wrap, $gap: 0.5rem);

    margin-top: var(--gutter-small);

    line-height: 2rem;
    @include ftsize(sm);

    .-name {
      padding: 0 0.75em;

      @include label();
      @include bdradi();
      @include linesd(--bd-main);

      &._active {
        @include fgcolor(primary, 5);
        @include linesd(primary, 5, $ndef: true);
      }
    }

    button {
      background-color: transparent;
      padding: 0 0.5rem !important;

      > :global(svg) {
        margin-top: -0.125rem;
        width: 1rem;
        height: 1rem;
      }
    }
  }

  .-hide {
    @include fluid(display, none, $md: inline-block);
  }

  .chinfo {
    @include flex($gap: 0.5rem);
    margin: var(--verpad) 0;

    .-left {
      display: flex;
      flex: 1;
      margin: 0.25rem 0;
      line-height: 1.75rem;
      transform: translateX(1px);
      @include fluid(font-size, 13px, 14px);
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
      margin: var(--gutter-sm) auto;
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
    }
  }
</style>
