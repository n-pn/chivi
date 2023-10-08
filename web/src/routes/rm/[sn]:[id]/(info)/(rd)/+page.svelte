<script lang="ts">
  import { page } from '$app/stores'
  import { invalidate } from '$app/navigation'

  import { get_user } from '$lib/stores'
  const _user = get_user()

  import SIcon from '$gui/atoms/SIcon.svelte'
  import RTime from '$gui/atoms/RTime.svelte'
  import Footer from '$gui/sects/Footer.svelte'

  import Mpager, { Pager } from '$gui/molds/Mpager.svelte'

  import ChapList from './ChapList.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: rstem = data.rstem
  $: chmax = rstem.chap_count
  $: pager = new Pager($page.url, { pg: 1 })

  let _loading = false
  let btn_icon = 'refresh'
  let err_text = ''

  let free_chap = 40

  $: {
    free_chap = Math.floor((rstem.chap_count * rstem.gifts) / 4)
    if (free_chap < 40) free_chap = 40
  }

  async function reload(crawl = 1, regen = false) {
    const { sname, sn_id } = rstem

    btn_icon = 'loader-2'
    _loading = true

    const url = `/_rd/rmstems/${sname}/${sn_id}?crawl=${crawl}&regen=${regen}`
    const res = await fetch(url)
    _loading = false

    if (!res.ok) {
      btn_icon = 'refresh'
      err_text = await res.text()
    } else {
      btn_icon = 'check'
      await invalidate(`rm:clist:${sname}:${sn_id}`)
      rstem = await res.json()
    }
  }
</script>

<header class="info">
  <span class="left">
    <info-text>{rstem.sname}</info-text>
    <info-span>{chmax} chương</info-span>
    <info-span class="u-show-pl"><RTime mtime={rstem.update_int} /></info-span>
  </span>

  <span class="right">
    <button
      class="m-btn _success _fill"
      disabled={$_user.privi < 0}
      on:click={() => reload(2)}
      data-tip="Cập nhật từ nguồn ngoài hoặc dịch lại nội dung"
      data-tip-loc="bottom"
      data-tip-pos="right">
      <SIcon name={btn_icon} spin={_loading} />
      <span>Đổi mới</span>
    </button>
  </span>
</header>

{#if err_text}<div class="form-msg _err">{err_text}</div>{/if}

{#if rstem.rlink}
  <div class="form-msg">
    <SIcon name="alert-triangle" />
    Danh sách chương tiết được liên kết tới
    <a class="m-link" href={rstem.rlink} rel="noreferrer" target="_blank"
      >nguồn ngoài
      <SIcon name="external-link" />
    </a>. Bấm [Đổi mới] để cập nhật nếu thấy nội dung bị lỗi thời.
  </div>
{/if}

<div class="form-msg">
  <SIcon name="alert-circle" />
  {#if free_chap < chmax}
    <span>
      Chương từ <span class="em">1</span> tới
      <span class="em">{free_chap}</span> cần
      <strong class="em">đăng nhập</strong> để xem nội dung.
    </span>

    <span>
      Chương từ <span class="em">{free_chap + 1}</span> tới
      <span class="em">{chmax}</span> cần
      <strong class="em">thanh toán vcoin</strong> để mở khoá.
    </span>
  {:else}
    <span>
      Bạn cần thiết
      <strong class="em">đăng nhập</strong> để xem nội dung các chương.
    </span>
  {/if}
</div>

{#if chmax > 0}
  <chap-list>
    <ChapList chaps={data.lasts} bhref={data.sroot} />
    <div class="chlist-sep" />
    <ChapList chaps={data.chaps} bhref={data.sroot} />

    <Footer>
      <div class="foot">
        <Mpager
          {pager}
          pgidx={data.pg_no}
          pgmax={Math.floor((chmax - 1) / 32) + 1} />
      </div>
    </Footer>
  </chap-list>
{:else}
  <div class="empty">
    <h3>Chưa có nội dung.</h3>
    <p>Bấm [Đổi mới] phía trên để cập nhật nội dung!</p>
  </div>
{/if}

<style lang="scss">
  @mixin label {
    font-weight: 500;
    text-transform: uppercase;
    @include fgcolor(tert);
  }

  .info {
    display: flex;
    padding: 0.75rem 0;
    @include border(--bd-main, $loc: bottom);

    // @include bgcolor(main);
    // @include bdradi(1rem, $loc: top);
  }

  .left {
    display: flex;
    flex: 1;
    margin: 0.25rem 0;
    line-height: 1.75rem;
    // transform: translateX(1px);
    @include bps(font-size, 13px, 14px);
  }

  .right {
    @include flex($gap: 0.5rem);
  }

  .form-msg {
    // @include flex-cx($gap: 0.5rem);

    margin: 0.5rem 0;

    .em {
      @include fgcolor(warning, 5);
      font-weight: 500;
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
</style>
