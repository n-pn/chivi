<script context="module">
  import Cvdata, { toggle_lookup, active_upsert } from '$layout/Cvdata'
  import { active as upsert_active } from '$widget/Upsert'

  import { get_nvinfo } from '$api/nvinfo_api'
  import { get_chinfo, get_chtext } from '$api/chtext_api'

  import { u_power } from '$src/stores'

  import {
    dname as lookup_dname,
    enabled as lookup_enabled,
    actived as lookup_actived,
    sticked as lookup_sticked,
  } from '$widget/Lookup'

  export async function preload({ params, query }) {
    const [err1, nvinfo] = await get_nvinfo(this.fetch, params.book)
    if (err1) return this.error(404, nvinfo)

    const [chidx, sname] = params.chap.split('-').reverse()
    const [snvid] = nvinfo['$' + sname] || [nvinfo.bhash]

    if (!snvid) return this.error(404, 'Nguồn truyện không tồn tại!')
    const chinfo = { sname, snvid, chidx }

    let mode = 0
    if (query.mode) mode = +query.mode

    const [err, data] = await get_chinfo(this.fetch, nvinfo.bhash, chinfo, mode)

    if (err) this.error(err, data)
    else return { ...data, nvinfo, changed: mode < 0 }
  }

  function gen_paths({ bslug }, { sname, chidx, prev_url, next_url }) {
    const book_path = gen_book_path(bslug, sname, 0)
    const list_path = gen_book_path(bslug, sname, chidx)

    const prev_path = prev_url ? `/~${bslug}/${prev_url}` : book_path
    const next_path = next_url ? `/~${bslug}/${next_url}` : list_path

    return [book_path, list_path, prev_path, next_path]
  }

  function gen_book_path(bslug, sname, chidx) {
    let url = `/~${bslug}/content?sname=${sname}`
    const page = Math.floor((chidx - 1) / 30) + 1
    return page > 1 ? url + `&page=${page}` : url
  }
</script>

<script>
  import SIcon from '$blocks/SIcon'
  import Vessel from '$layout/Vessel'

  export let nvinfo = {}
  export let chinfo = {}
  export let cvdata = ''

  export let changed = false
  $: if ($u_power > 0 && changed) reload_chap()

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
</script>

<svelte:head>
  <title>{chinfo.title} - {nvinfo.btitle_vi} - Chivi</title>
</svelte:head>

<svelte:body on:keydown={handle_keypress} />

<Vessel shift={$lookup_enabled && $lookup_actived && $lookup_sticked}>
  <a slot="header-left" href={book_path} class="header-item _title">
    <SIcon name="book-open" />
    <span class="header-text _show-md _title">{nvinfo.btitle_vi}</span>
  </a>

  <button slot="header-left" class="header-item _active">
    <span class="header-text _seed">[{chinfo.sname}]</span>
  </button>

  <button
    slot="header-right"
    class="header-item"
    disabled={$u_power < 1}
    on:click={reload_chap}
    data-kbd="r">
    <SIcon name="refresh-ccw" spin={_reload} />
  </button>

  <button
    slot="header-right"
    class="header-item"
    class:_active={$lookup_enabled}
    on:click={toggle_lookup}
    data-kbd="\">
    <SIcon name="compass" />
  </button>
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

    .-crumb {
      display: inline;
      // float: left;
      @include fgcolor(neutral, 6);

      &._sep:after {
        content: '>';
        @include fgcolor(neutral, 5);
        padding: 0 0.25rem;
      }
    }

    .-link {
      color: inherit;
      &:hover {
        @include fgcolor(primary, 6);
      }
    }

    :global(svg) {
      margin-top: -0.25rem;
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
</style>
