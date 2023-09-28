<script lang="ts">
  import { page } from '$app/stores'

  import { get_user } from '$lib/stores'
  const _user = get_user()

  import SIcon from '$gui/atoms/SIcon.svelte'
  import RTime from '$gui/atoms/RTime.svelte'
  import Footer from '$gui/sects/Footer.svelte'

  import Mpager, { Pager } from '$gui/molds/Mpager.svelte'

  import ChapList from './ChapList.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ ustem, lasts, chaps, pg_no } = data)

  $: chmax = ustem.chap_count
  $: pager = new Pager($page.url, { pg: 1 })

  let _onload = false
  let err_msg: string

  // $: is_owner = data.sname == '@' + $_user.uname

  $: base_href = `/up/${data.sname}:${data.up_id}`

  // prettier-ignore
  const privi_str = (privi: number) => privi < 1 ? 'đăng nhập' : `quyền hạn ${privi}`
</script>

<page-info>
  <info-left>
    <info-text>{ustem.sname}</info-text>
    <info-span>{chmax} chương</info-span>
    <info-span class="u-show-pl"><RTime mtime={ustem.mtime} /></info-span>
  </info-left>
</page-info>

{#if err_msg}
  <div class="chap-hint _error">{err_msg}</div>
{/if}

<div class="chap-hint">
  <SIcon name="alert-circle" />
  <span>
    Chương từ <span class="em">1</span> tới
    <span class="em">{Math.floor(chmax / 2)}</span> cần
    <strong class="em">đăng nhập</strong> để xem nội dung.
  </span>

  <span>
    Chương từ <span class="em">{Math.floor(chmax / 2) + 1}</span> tới
    <span class="em">{chmax}</span> cần
    <strong class="em">{privi_str(2)}</strong> để xem nội dung.
  </span>
</div>

{#if chmax > 0}
  <chap-list>
    <ChapList {ustem} chaps={lasts} bhref={base_href} />
    <div class="chlist-sep" />
    <ChapList {ustem} {chaps} bhref={base_href} />

    <Footer>
      <div class="foot">
        <Mpager
          {pager}
          pgidx={pg_no}
          pgmax={Math.floor((chmax - 1) / 32) + 1} />
      </div>
    </Footer>
  </chap-list>
{:else}
  <p class="empty">Không có nội dung :(</p>
{/if}

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
