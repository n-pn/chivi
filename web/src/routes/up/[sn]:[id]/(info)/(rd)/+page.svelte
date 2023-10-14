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

  $: ({ ustem, lasts, chaps, pg_no, sroot } = data)

  $: chmax = ustem.chap_count
  $: pager = new Pager($page.url, { pg: 1 })

  let _onload = false
  let err_msg: string

  // $: is_owner = data.sname == '@' + $_user.uname

  let free_chaps = 0

  $: {
    free_chaps = Math.floor((ustem.chap_count * ustem.gifts) / 4)
    if (free_chaps > 120) free_chaps = 120
  }
</script>

<page-info>
  <info-left>
    <info-text>{ustem.sname}</info-text>
    <info-span>{chmax} chương</info-span>
    <info-span class="u-show-pl"><RTime mtime={ustem.mtime} /></info-span>
  </info-left>
</page-info>

{#if err_msg}<div class="form-msg _error">{err_msg}</div>{/if}

{#if chmax > 0}
  <div class="form-msg">
    <SIcon name="alert-circle" />
    <span>
      Chương từ <span class="u-warn">{free_chaps + 1}</span> cần
      <strong class="u-warn">thanh toán vcoin</strong> để mở khoá.
    </span>
  </div>

  <chap-list>
    <ChapList chaps={lasts} bhref={sroot} />
    <div class="chlist-sep" />
    <ChapList {chaps} bhref={sroot} />

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
  <p class="d-empty">Không có nội dung :(</p>
{/if}

<style lang="scss">
  @mixin label {
    font-weight: 500;
    text-transform: uppercase;
    @include fgcolor(tert);
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

  info-right {
    @include flex($gap: 0.5rem);
  }

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

  .foot {
    margin-top: 1rem;
  }
</style>
