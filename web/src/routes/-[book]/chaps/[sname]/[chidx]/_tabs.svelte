<script lang="ts">
  import { session } from '$app/stores'
  import { SIcon } from '$gui'

  export let nvinfo: CV.Nvinfo
  export let nslist: CV.Nslist
  export let nvseed: CV.Nvseed

  export let chmeta: CV.Chmeta
  export let chinfo: CV.Chinfo

  $: self_seed = nslist.users.find((x) => x.sname == '@' + $session.uname)

  let show_users = false
  let show_other = false

  function chap_href(sname: string) {
    return `/-${nvinfo.bslug}/chaps/${sname}/${chinfo.chidx}`
  }
</script>

<nav class="nslist">
  {#if nvseed.sname != '=base' && nvseed.sname != self_seed.sname}
    <a
      class="nvseed umami--click-chtext-switch"
      class:_active={nvseed.sname == chmeta.sname}
      class:_hidden={nvseed.chaps < chinfo.chidx}
      href={chap_href(nvseed.sname)}
      rel="nofollow">
      <span class="nvseed-name">{nvseed.sname}</span>
    </a>
  {/if}

  <a
    class="nvseed umami--click-chtext-switch"
    class:_active={nslist._base.sname == chmeta.sname}
    class:_hidden={nslist._base.chaps < chinfo.chidx}
    href={chap_href(nslist._base.sname)}>
    <span class="nvseed-name">Mặc định</span>
  </a>

  <button
    class="nvseed _btn"
    class:_focus={show_other}
    on:click={() => (show_other = !show_other)}>
    <span class="nvseed-name">Tải ngoài</span>
    <span class="nvseed-more">({nslist.other.length})</span>
  </button>

  <button
    class="nvseed _btn"
    class:_focus={show_users}
    on:click={() => (show_users = !show_users)}>
    <span class="nvseed-name">Người dùng</span>
    <span class="nvseed-more">({nslist.users.length})</span>
  </button>

  {#if self_seed}
    <a
      class="nvseed umami--click-chtext-switch"
      class:_active={self_seed.sname == chmeta.sname}
      class:_hidden={self_seed.chaps < chinfo.chidx}
      href={chap_href(self_seed.sname)}
      rel="nofollow">
      <span class="nvseed-name">Của bạn</span>
    </a>
  {/if}
</nav>

{#if show_other}
  <nav class="nslist">
    {#each nslist.other as nvseed}
      <a
        class="nvseed umami--click-chtext-switch"
        class:_active={nvseed.sname == chmeta.sname}
        class:_hidden={nvseed.chaps < chinfo.chidx}
        href={chap_href(nvseed.sname)}
        rel="nofollow">
        <span class="nvseed-name">{nvseed.sname}</span>
      </a>
    {/each}
  </nav>
{/if}

{#if show_users}
  <nav class="nslist">
    {#each nslist.users as nvseed}
      <a
        class="nvseed umami--click-chtext-switch"
        class:_active={nvseed.sname == chmeta.sname}
        class:_hidden={nvseed.chaps < chinfo.chidx}
        href={chap_href(nvseed.sname)}
        rel="nofollow">
        <span class="nvseed-name">{nvseed.sname}</span>
      </a>
    {/each}
  </nav>
{/if}

<style lang="scss">
  .nslist {
    @include flex-cx($gap: 0.375rem);
    flex-wrap: wrap;
    margin-bottom: 0.5rem;
  }

  .nvseed {
    display: flex;
    @include bdradi();
    @include linesd(--bd-main);
    padding: 0 0.375rem;
    line-height: 1.75rem;

    @include fgcolor(tert);
    font-size: rem(12px);
    font-weight: 500;
    text-transform: uppercase;

    &._btn {
      background: transparent;
    }

    &._active {
      @include linesd(primary, 5, $ndef: false);
    }

    // prettier-ignore
    &._active, &:hover, &:active {
      @include fgcolor(primary, 5);
    }

    &._focus {
      @include fgcolor(secd);
    }

    &._hidden {
      @include linesd(--bd-soft, $ndef: false);

      > .nvseed-name {
        @include fgcolor(mute);
      }
    }
  }

  .nvseed-more {
    font-size: rem(13px);
    margin-left: 0.25rem;
  }
</style>
