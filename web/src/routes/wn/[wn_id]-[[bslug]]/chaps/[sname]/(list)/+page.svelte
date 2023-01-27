<script lang="ts">
  import { page } from '$app/stores'
  import { session } from '$lib/stores'

  import { api_path } from '$lib/api_call'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import RTime from '$gui/atoms/RTime.svelte'
  import ChapList from './ChapList.svelte'
  import Footer from '$gui/sects/Footer.svelte'

  import Mpager, { Pager } from '$gui/molds/Mpager.svelte'
  import { rel_time } from '$utils/time_utils'
  import { invalidateAll } from '$app/navigation'
  import Gmenu from '$gui/molds/Gmenu.svelte'

  import type { PageData } from './$types'
  import { seed_path } from '$lib/kit_path'
  export let data: PageData

  $: ({ nvinfo, ubmemo, curr_seed, seed_data, chaps, pg_no } = data)

  $: pager = new Pager($page.url, { pg: 1 })

  let _refresh = false
  let _error: string

  async function reload_source() {
    _refresh = true
    _error = ''

    const args = [nvinfo.id, curr_seed.sname]
    const res = await fetch(api_path('chroots.show', args, null, { mode: 1 }))

    if (res.ok) invalidateAll()
    else _error = await res.text()
    _refresh = false
  }

  function can_add_chaps(sname: string) {
    const _privi = $session.privi

    if (sname == '_') return _privi > 0
    if (!sname.startsWith('@')) return _privi > 2

    return sname == '@' + $session.uname
  }

  $: base_path = seed_path(nvinfo.bslug, curr_seed.sname, curr_seed.snvid)
</script>

<article class="article island">
  <page-info>
    <info-left>
      <info-text
        >{curr_seed.sname != '_' ? curr_seed.sname : 'Tổng hợp'}</info-text>
      <info-span>{curr_seed.chmax} chương</info-span>
      <info-span><RTime mtime={curr_seed.utime} /></info-span>
    </info-left>

    <info-right>
      {#if curr_seed.stype == 0 && can_add_chaps(curr_seed.sname)}
        <a
          class="m-btn _primary _fill"
          class:_disable={$session.privi < 1}
          href="
          {base_path}/+chap?start={curr_seed.chmax + 1}"
          data-tip="Yêu cầu quyền hạn: 1">
          <SIcon name="upload" />
          <span class="-hide">Thêm chương</span>
        </a>
      {:else}
        <button
          class="m-btn _primary"
          disabled={$session.privi < 0}
          data-tip="Yêu cầu quyền hạn: Đăng nhập"
          on:click={reload_source}>
          <SIcon name={_refresh ? 'loader' : 'refresh'} spin={_refresh} />
          <span class="-hide">Cập nhật</span>
        </button>
      {/if}

      <Gmenu dir="right">
        <button class="m-btn" slot="trigger">
          <SIcon name="menu-2" />
          <span class="-hide">Nâng cao</span>
        </button>

        <svelte:fragment slot="content">
          {#if curr_seed.stype == 0 && can_add_chaps(curr_seed.sname)}
            <button
              class="gmenu-item"
              disabled={$session.privi < 0}
              on:click={reload_source}>
              <SIcon name={_refresh ? 'loader' : 'refresh'} spin={_refresh} />
              <span class="-hide">Đổi mới</span>
            </button>
          {:else}
            <a
              class="gmenu-item"
              href={seed_data.slink}
              target="_blank"
              rel="external noopener noreferrer">
              <SIcon name="external-link" />
              <span>Liên kết</span>
            </a>
          {/if}

          <a
            class="gmenu-item"
            class:_disable={$session.privi < 1}
            href="/-{nvinfo.bslug}/chaps/{curr_seed.sname}/+edit">
            <SIcon name="settings" />
            <span>Cài đặt</span>
          </a>
        </svelte:fragment>
      </Gmenu>
    </info-right>
  </page-info>

  {#if _error}<div class="error">{_error}</div>{/if}
  <div class="chap-hint">
    <span>Gợi ý:</span>
    <span class="-hint" class:_bold={!seed_data.fresh}
      >Bấm "<SIcon name="refresh" /> Đổi mới" để cập nhật danh sách chương tiết.</span>
    <span class="-stat"
      >Lần cập nhật cuối: <strong>{rel_time(seed_data.stime)}</strong>.</span>
  </div>

  <chap-list>
    {#if chaps.length > 0}
      <ChapList
        {nvinfo}
        {ubmemo}
        nvseed={curr_seed}
        chaps={data.top_chaps}
        privi_map={seed_data.privi_map} />
      <div class="chlist-sep" />
      <ChapList
        {nvinfo}
        {ubmemo}
        nvseed={curr_seed}
        {chaps}
        privi_map={seed_data.privi_map} />

      <Footer>
        <div class="foot">
          <Mpager
            {pager}
            pgidx={pg_no}
            pgmax={Math.floor((curr_seed.chmax - 1) / 32) + 1} />
        </div>
      </Footer>
    {:else}
      <p class="empty">Không có nội dung :(</p>
    {/if}
  </chap-list>
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

    .-hint._bold {
      @include fgcolor(warning, 5);
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

  .error {
    font-size: italic;
    @include fgcolor(harmful, 5);
    @include ftsize(sm);
  }
</style>
