<script lang="ts">
  import { page } from '$app/stores'

  import { get_user } from '$lib/stores'
  const _user = get_user()

  import { invalidateAll } from '$app/navigation'
  import { seed_path } from '$lib/kit_path'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import RTime from '$gui/atoms/RTime.svelte'
  import Footer from '$gui/sects/Footer.svelte'

  import Mpager, { Pager } from '$gui/molds/Mpager.svelte'
  import Gmenu from '$gui/molds/Gmenu.svelte'

  import ChapList from './ChapList.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ nvinfo, ubmemo, curr_seed, seed_data, chaps, pg_no } = data)

  $: pager = new Pager($page.url, { pg: 1 })

  let _onload = false
  let err_msg: string

  async function reload_chlist(_mode = 1) {
    _onload = true
    err_msg = ''

    const api_url = `/_wn/seeds/${nvinfo.id}/${curr_seed.sname}/reload`
    const headers = { Accept: 'application/json' }
    const api_res = await fetch(api_url, { headers })
    _onload = false

    if (!api_res.ok) {
      const data = await api_res.json()
      err_msg = data.message
    } else {
      await invalidateAll()
    }
  }

  $: [can_upsert, can_reload] = check_edit_privi(
    curr_seed.sname,
    seed_data.edit_privi,
    $_user
  )

  const check_edit_privi = (
    sname: string,
    edit_privi: number,
    user: App.CurrentUser
  ): [boolean, boolean] => {
    if (user.privi > 3) return [true, true]

    if (sname[0] == '@') {
      const owner = sname == '@' + user.uname
      return [owner && user.privi > 1, owner && user.privi > 0]
    } else {
      return [user.privi >= edit_privi, user.privi >= edit_privi - 1]
    }
  }

  $: edit_href = `${seed_path(nvinfo.bslug, curr_seed.sname)}/+bulk`

  // prettier-ignore
  const privi_str = (privi: number) => privi < 1 ? 'đăng nhập' : `quyền hạn ${privi}`
</script>

<article class="article island">
  <page-info>
    <info-left>
      <info-text>{curr_seed.sname}</info-text>
      <info-span>{curr_seed.chmax} chương</info-span>
      <info-span class="u-show-pl"><RTime mtime={curr_seed.utime} /></info-span>
    </info-left>

    <info-right>
      <a
        class="m-btn _primary _fill"
        class:_disable={!can_upsert}
        href="{edit_href}?start={curr_seed.chmax + 1}"
        data-tip="Tự thêm nội dung chương tiết cho nguồn truyện"
        data-tip-loc="bottom"
        data-tip-pos="right">
        <SIcon name="upload" />
        <span class="-hide">Thêm text</span>
      </a>

      {#if seed_data.rlink}
        <button
          class="m-btn _primary"
          disabled={!can_reload}
          on:click={() => reload_chlist(2)}
          data-tip="Cập nhật danh sách chương tiết từ nguồn ngoài"
          data-tip-loc="bottom"
          data-tip-pos="right">
          <SIcon name={_onload ? 'loader-2' : 'refresh'} spin={_onload} />
          <span class="-hide">Đổi mới</span>
        </button>
      {/if}

      <Gmenu dir="right">
        <button class="m-btn" slot="trigger">
          <SIcon name="menu-2" />
        </button>

        <svelte:fragment slot="content">
          <a
            class="gmenu-item"
            class:_disable={!can_upsert}
            href="/wn/{nvinfo.bslug}/ch/{curr_seed.sname}/+conf">
            <SIcon name="settings" />
            <span>Cài đặt</span>
          </a>
          <a
            class="gmenu-item"
            class:_disable={$_user.privi < 1}
            href="/wn/{nvinfo.bslug}/ch/{curr_seed.sname}/+down">
            <SIcon name="download" />
            <span>Tải xuống</span>
          </a>

          <button
            class="gmenu-item"
            class:_disable={$_user.privi < 0}
            on:click={() => reload_chlist(-1)}>
            <SIcon name="language" />
            <span>Dịch lại</span>
          </button>
        </svelte:fragment>
      </Gmenu>
    </info-right>
  </page-info>

  {#if err_msg}
    <div class="chap-hint _error">{err_msg}</div>
  {/if}

  {#if seed_data.rlink}
    <div class="chap-hint" class:_bold={!seed_data.fresh}>
      <SIcon name="alert-triangle" />
      Danh sách chương tiết được liên kết tới
      <a class="link" href={seed_data.rlink} rel="noreferrer" target="_blank"
        >nguồn ngoài
        <SIcon name="external-link" />
      </a>. Bạn có thể bấm [<SIcon name="refresh" /> Đổi mới] để cập nhật theo nguồn
      ngoài.
    </div>
  {/if}

  {#if seed_data.read_privi > -1}
    <div class="chap-hint">
      <SIcon name="alert-circle" />
      {#if seed_data.read_privi > 0}
        <span>
          Chương từ <span class="em">1</span> tới
          <span class="em">{seed_data.gift_chaps}</span> cần
          <strong class="em">{privi_str(seed_data.read_privi - 1)}</strong> để xem
          nội dung.
        </span>
      {/if}

      {#if curr_seed.chmax > seed_data.gift_chaps}
        <span>
          Chương từ <span class="em">{seed_data.gift_chaps + 1}</span> tới
          <span class="em">{curr_seed.chmax}</span> cần
          <strong class="em">{privi_str(seed_data.read_privi)}</strong> để xem nội
          dung.
        </span>
      {/if}
    </div>
  {/if}

  {#if curr_seed.chmax > 0}
    <chap-list>
      <ChapList
        {nvinfo}
        {ubmemo}
        {curr_seed}
        {seed_data}
        chaps={data.top_chaps} />
      <div class="chlist-sep" />
      <ChapList {nvinfo} {ubmemo} {curr_seed} {seed_data} {chaps} />

      <Footer>
        <div class="foot">
          <Mpager
            {pager}
            pgidx={pg_no}
            pgmax={Math.floor((curr_seed.chmax - 1) / 32) + 1} />
        </div>
      </Footer>
    </chap-list>
  {:else}
    <p class="empty">Không có nội dung :(</p>
  {/if}
</article>

<style lang="scss">
  @mixin label {
    font-weight: 500;
    text-transform: uppercase;
    @include fgcolor(tert);
  }

  .article {
    @include padding-y(0);
  }

  page-info {
    display: flex;
    padding: 0.75rem 0;
    @include border(--bd-main, $loc: bottom);

    // @include bgcolor(main);
    // @include bdradi(1rem, $loc: top);
  }

  info-left {
    display: flex;
    flex: 1;
    margin: 0.25rem 0;
    line-height: 1.75rem;
    // transform: translateX(1px);
    @include bps(font-size, 13px, 14px);
  }

  .-hide {
    @include bps(display, none, $tm: inline-block);
  }

  info-right {
    @include flex($gap: 0.5rem);
  }

  .chap-hint {
    // text-align: center;
    // font-style: italic;
    // @include flex-cx($gap: 0.5rem);
    margin: 0.5rem 0;

    @include ftsize(sm);
    @include fgcolor(tert);

    &._bold {
      font-weight: 500;
    }

    .em {
      @include fgcolor(warning, 5);
      font-weight: 500;
    }

    &._error {
      font-size: italic;
      @include fgcolor(harmful, 5);
    }

    :global(svg) {
      display: inline-block;
      margin-bottom: 0.1em;
    }
  }

  // .m-btn {
  //   background: inherit;

  //   &:hover {
  //     @include bgcolor(secd);
  //   }
  // }
  // .chinfo {
  //   margin-bottom: var(--gutter-pl);
  // }

  info-text {
    padding-left: 0.5rem;
    @include label();
    @include fgcolor(tert);
    @include border(primary, 5, $width: 3px, $loc: left);
  }

  info-span {
    font-style: italic;
    @include fgcolor(neutral, 4);

    &:before {
      display: inline-block;
      content: '·';
      text-align: center;
      @include bps(width, 0.5rem, 0.75rem, 1rem);
    }
  }

  chap-list {
    display: block;
    padding-bottom: 0.75rem;
  }

  .chlist-sep {
    width: 70%;
    margin: var(--gutter) auto;
    @include border(--bd-main, $loc: bottom);
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

  .link {
    @include fgcolor(primary, 5);
    &:hover {
      @include fgcolor(primary, 6);
    }
  }
</style>
