<script context="module">
  import Cvdata, {
    toggle_lookup,
    active_upsert,
  } from '$lib/layouts/Cvdata.svelte'
  import { active as upsert_active } from '$lib/widgets/Upsert.svelte'

  import { get_chinfo, get_chtext } from '$api/chtext_api'

  import {
    dname as lookup_dname,
    enabled as lookup_enabled,
    actived as lookup_actived,
    sticked as lookup_sticked,
  } from '$lib/widgets/Lookup.svelte'

  export async function load({ fetch, page: { params, query }, context }) {
    const { nvinfo } = context

    const [chidx, sname] = params.chap.split('-').reverse()
    const [snvid] = nvinfo.chseed[sname] || [nvinfo.bhash]
    if (!snvid) {
      return { status: 404, error: new Error('Nguồn truyện không tồn tại!') }
    }

    const chinfo = { sname, snvid, chidx }

    const mode = +query.get('mode') || 0
    const [err, data] = await get_chinfo(fetch, nvinfo.bhash, chinfo, mode)

    if (err) return { status: 404, error: new Error(data) }

    return {
      props: {
        ...data,
        nvinfo,
        changed: mode < 0,
      },
    }
  }
</script>

<script>
  import { session } from '$app/stores'

  import SIcon from '$lib/blocks/SIcon.svelte'
  import Vessel from '$lib/layouts/Vessel.svelte'
  import Error from '../__error.svelte'

  export let nvinfo = {}
  export let chinfo = {}
  export let cvdata = ''

  export let changed = false
  $: if ($session.privi > 0 && changed) reload_chap()

  $: [book_path, list_path, prev_path, next_path] = gen_paths(nvinfo, chinfo)
  $: $lookup_dname = nvinfo.bhash

  // $: $lookup_enabled = false
  // $: $lookup_actived = false

  function handle_keypress(evt) {
    if (evt.ctrlKey) return
    if ($upsert_active) return

    switch (evt.key) {
      case '\\':
        evt.preventDefault()
        toggle_lookup()
        break

      case 'x':
        evt.preventDefault()
        active_upsert(0)
        break

      case 'c':
        evt.preventDefault()
        active_upsert(1)
        break

      case 'v':
        evt.preventDefault()
        active_upsert(3)
        break

      case 'h':
      case 'j':
      case 'k':
      case 'r':
        let elm = document.querySelector(`[data-kbd="${evt.key}"]`)
        if (elm) {
          evt.preventDefault()
          elm.click()
        }

        break
      default:
        if (evt.keyCode == 13) {
          evt.preventDefault()
          active_upsert()
        }
    }
  }

  let _reload = false
  async function reload_chap() {
    changed = false

    _reload = true
    const [_, data] = await get_chtext(window.fetch, nvinfo.bhash, chinfo, 1)
    _reload = false

    cvdata = data
  }

  function gen_paths({ bslug }, { sname, chidx, prev_url, next_url }) {
    const book_path = gen_book_path(bslug, sname, 0)
    const list_path = gen_book_path(bslug, sname, chidx)

    const prev_path = prev_url ? `/~${bslug}/${prev_url}` : book_path
    const next_path = next_url ? `/~${bslug}/${next_url}` : list_path

    return [book_path, list_path, prev_path, next_path]
  }

  function gen_book_path(bslug, sname, chidx) {
    let url = `/~${bslug}/chaps?sname=${sname}`
    const page = Math.floor((chidx - 1) / 30) + 1
    return page > 1 ? url + `&page=${page}` : url
  }
</script>

<svelte:head>
  <title>{chinfo.title} - {nvinfo.btitle_vi} - Chivi</title>
</svelte:head>

<svelte:body on:keydown={handle_keypress} />

<Vessel shift={$lookup_enabled && $lookup_actived && $lookup_sticked}>
  <svelte:fragment slot="header-left">
    <a href={book_path} class="header-item _title">
      <SIcon name="book-open" />
      <span class="header-text _show-md _title">{nvinfo.btitle_vi}</span>
    </a>

    <button class="header-item _active">
      <span class="header-text _seed">[{chinfo.sname}]</span>
    </button>
  </svelte:fragment>

  <svelte:fragment slot="header-right">
    <button
      class="header-item"
      disabled={$session.privi < 1}
      on:click={reload_chap}
      data-kbd="r">
      <SIcon name="refresh-ccw" spin={_reload} />
    </button>

    <button
      class="header-item"
      class:_active={$lookup_enabled}
      on:click={toggle_lookup}
      data-kbd="\">
      <SIcon name="compass" />
    </button>
  </svelte:fragment>

  <nav class="bread">
    <div class="-crumb _sep">
      <a href="/~{nvinfo.bslug}" class="-link"> {nvinfo.btitle_vi}</a>
    </div>

    <div class="-crumb"><span class="-text">{chinfo.label}</span></div>
  </nav>

  {#if cvdata}
    <Cvdata
      {cvdata}
      bind:changed
      dname={nvinfo.bhash}
      bname={nvinfo.btitle_vi} />
  {:else}
    <div class="empty">
      <h1>Chương tiết không có nội dung.</h1>
      <p>Một số khả năng:</p>
      <ul>
        <li>
          Javascript chưa được bật.
          <p>Hoặc là bạn đang xem nội dung trang web qua bên thứ ba.</p>
        </li>
        <li>
          Chưa có text tiếng trung trên server, phải tải từ các nguồn ngoài.
          <p>Việc này hiện nay có một số hạn chế nhất định:</p>
          <ul>
            <li>
              Các nguồn <strong>xbiquge</strong>, <strong>hetushu</strong> hay
              <strong>duokan8</strong> cần thiết bạn phải đăng nhập.
            </li>
            <li>
              Các nguồn <strong>zhwenpg</strong>, <strong>69shu</strong> hay
              <strong>paoshu8</strong> chỉ dành cho power users.
              <br />
              (Nguồn <strong>69shu</strong> hiện tại đang gặp lỗi.)
            </li>

            <li>
              Các nguồn <strong>shubaow</strong>, <strong>jx_la</strong> hiện nay
              không hoạt động.
            </li>
          </ul>
        </li>
      </ul>
      <p>
        <em>
          Lưu ý: Hiện nay thì mọi người đều xem được các chương tiết đã được lưu
          trữ trên server, nhưng điều này có thể thay đổi trong tương lai!
        </em>
      </p>
    </div>
  {/if}

  <div class="footer" slot="footer">
    <a
      href={prev_path}
      class="m-button _solid"
      class:_disable={!chinfo.prev_url}
      data-kbd="j">
      <SIcon name="chevron-left" />
      <span>Trước</span>
    </a>

    <a href={list_path} class="m-button _solid" data-kbd="h">
      <SIcon name="list" />
      <span>{chinfo.chidx}/{chinfo.total}</span>
    </a>

    <a
      href={next_path}
      class="m-button _solid _primary"
      class:_disable={!chinfo.next_url}
      data-kbd="k">
      <span>Kế tiếp</span>
      <SIcon name="chevron-right" />
    </a>
  </div>
</Vessel>

<style lang="scss">
  .footer {
    width: 100%;
    padding: 0.5rem 0;
    @include flex($center: content);
    @include flex-gap($gap: 0.5rem, $child: ':global(*)');
  }

  .bread {
    padding: 0.5rem 0;
    line-height: 1.25rem;

    @include font-size(2);
    @include border($sides: bottom);

    @include tm-dark {
      @include bdcolor(neutral, 7);
    }

    .-crumb {
      display: inline;
      // float: left;
      @include fgcolor(neutral, 6);
      @include tm-dark {
        @include fgcolor(neutral, 5);
      }

      &._sep:after {
        content: ' > ';
      }
    }

    .-link {
      color: inherit;
      &:hover {
        @include fgcolor(primary, 6);
      }
    }
  }

  .empty {
    // height: calc(100vh - 10rem);
    margin: 3rem auto;
    max-width: 40rem;

    // font-style: italic;

    // @include flex($center: both);
    @include fgcolor(neutral, 7);

    h1 {
      font-weight: 500;
      @include font-size(7);
      @include fgcolor(neutral, 7);
    }

    li {
      margin-top: 0.75rem;
      li {
        margin-top: 0rem;
      }
    }

    :global(ul) {
      margin-top: 0.5rem;
    }

    p {
      margin-top: 0.5rem;
    }

    strong {
      font-weight: 500;
    }
  }

  .m-button {
    @include tm-dark {
      @include fgcolor(neutral, 2);
      @include bgcolor(neutral, 7);

      &:hover {
        @include bgcolor(neutral, 6);
      }

      &._primary {
        @include bgcolor(primary, 7);

        &:hover {
          @include bgcolor(primary, 6);
        }
      }
    }
  }
</style>
