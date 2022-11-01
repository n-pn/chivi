<script lang="ts">
  import { page } from '$app/stores'
  import { session } from '$lib/stores'

  // $: {nvinfo, nvlist, nvseed, chmeta, chinfo} = $page.data
  export let nvinfo: CV.Nvinfo
  export let nslist: CV.Nslist
  export let nvseed: CV.Chroot

  export let chmeta: CV.Chmeta
  export let chinfo: CV.Chinfo

  $: self_name = '@' + $session.uname
  $: self_seed = nslist.users.find((x) => x.sname == self_name)

  $: user_seeds = nslist.users.filter((x) => x.chmax >= chinfo.chidx)
  $: misc_seeds = nslist.other.filter((x) => x.chmax >= chinfo.chidx)

  let show_users = false
  let show_other = false

  function chap_href(sname: string) {
    return `/-${nvinfo.bslug}/chaps/${sname}/${chinfo.chidx}`
  }
</script>

<nav class="nslist">
  {#if nvseed.sname != '=base' && nvseed.sname != self_name}
    <a
      class="nvseed"
      class:_active={nvseed.sname == chmeta.sname}
      class:_hidden={nvseed.chmax < chinfo.chidx}
      href={chap_href(nvseed.sname)}
      rel="nofollow">
      <span class="nvseed-name">{nvseed.sname}</span>
    </a>
  {/if}

  <a
    class="nvseed"
    class:_active={nslist._base.sname == chmeta.sname}
    class:_hidden={nslist._base.chmax < chinfo.chidx}
    href={chap_href(nslist._base.sname)}>
    <span class="nvseed-name">Tổng hợp</span>
  </a>

  {#if misc_seeds.length > 0}
    <button
      class="nvseed _btn"
      class:_focus={show_other}
      on:click={() => (show_other = !show_other)}>
      <span class="nvseed-name">Tải ngoài</span>
      <span class="nvseed-more">({misc_seeds.length})</span>
    </button>
  {/if}

  {#if user_seeds.length > 0}
    <button
      class="nvseed _btn"
      class:_focus={show_users}
      on:click={() => (show_users = !show_users)}>
      <span class="nvseed-name">Người dùng</span>
      <span class="nvseed-more">({user_seeds.length})</span>
    </button>
  {/if}

  {#if self_seed}
    <a
      class="nvseed"
      class:_active={self_seed.sname == chmeta.sname}
      href={chap_href(self_seed.sname)}
      rel="nofollow">
      <span class="nvseed-name">Của bạn</span>
    </a>
  {/if}
</nav>

{#if show_other}
  <nav class="nslist">
    {#each misc_seeds as nvseed}
      <a
        class="nvseed"
        class:_active={nvseed.sname == chmeta.sname}
        href={chap_href(nvseed.sname)}
        rel="nofollow">
        <span class="nvseed-name">{nvseed.sname}</span>
      </a>
    {/each}
  </nav>
{/if}

{#if show_users}
  <nav class="nslist">
    {#each user_seeds as nvseed}
      <a
        class="nvseed"
        class:_active={nvseed.sname == chmeta.sname}
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
