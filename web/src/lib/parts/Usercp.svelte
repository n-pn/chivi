<script>
  import { session } from '$app/stores'
  import { status_names, status_icons } from '$lib/constants'

  import SIcon from '$atoms/SIcon.svelte'
  import Slider from '$molds/Slider.svelte'

  import Config from './Usercp/Config.svelte'
  import Passwd from './Usercp/Passwd.svelte'

  export let actived = false
  export let section = 'main'

  async function logout() {
    $session = { uname: 'Khách', privi: -1 }
    await fetch('/api/user/logout')
  }

  let chaps = []
  $: if (actived) load_history(0)

  async function load_history(skip = 0) {
    if (section != 'main') return
    const res = await fetch(`/api/_self/books/access?skip=${skip}&take=15`)
    if (res.ok) chaps = await res.json()
    console.log(chaps.length)
  }
</script>

<Slider bind:actived _rwidth={26}>
  <svelte:fragment slot="header-left">
    <div class="-icon">
      <SIcon name="user" />
    </div>
    <div class="-text">{$session.uname} [{$session.privi}]</div>
  </svelte:fragment>

  <svelte:fragment slot="header-right">
    <button class="-btn" on:click={() => (section = 'config')}>
      <SIcon name="settings" />
    </button>
  </svelte:fragment>

  {#if section == 'main'}
    <div class="hint">
      <strong>Gợi ý:</strong> Bấm <SIcon name="settings" /> để thay đổi giao diện,
      chế độ dịch hoặc đổi mật khẩu.
    </div>
    <div class="chips">
      {#each ['reading', 'onhold', 'pending'] as status}
        <a href="/@{$session.uname}?bmark={status}" class="chip">
          <span class="chip-icon">
            <SIcon name={status_icons[status]} />
          </span>
          <span class="chip-text">
            {status_names[status]}
          </span>
        </a>
      {/each}
    </div>

    <div class="label">
      <SIcon name="clock" />
      <span>Lịch sử đọc</span>
    </div>

    <div class="chaps">
      {#each chaps as chap}
        <a
          class="chap"
          href="/-{chap.bslug}/-{chap.sname}/-{chap.uslug}-{chap.chidx}">
          <div class="chap-text">
            <div class="chap-title">{chap.title}</div>
            <div class="chap-chidx">{chap.chidx}.</div>
          </div>

          <div class="chap-meta">
            <div class="chap-bname">{chap.bname}</div>

            {#if chap.locked}
              <div class="chap-icon"><SIcon name="pin" /></div>
            {/if}
          </div>
        </a>
      {/each}
    </div>
  {:else}
    <div class="tabnav">
      <button class="m-button btn-back" on:click={() => (section = 'main')}>
        <SIcon name="arrow-left" />
        <span>Trở về</span>
      </button>

      <button class="m-button btn-back" on:click={logout}>
        <SIcon name="logout" />
        <span>Đăng xuất</span>
      </button>
    </div>

    <Config bind:actived />
    <Passwd bind:section />
  {/if}
</Slider>

<style lang="scss">
  @mixin label {
    font-weight: 500;
    text-transform: uppercase;
    @include fgcolor(tert);
  }

  .hint {
    margin: 0.75rem;
    margin-bottom: 0;
    @include ftsize(sm);
    @include fgcolor(tert);
  }

  .label {
    @include flex();
    margin: 0.25rem 0.375rem;
    padding: 0 0.5rem;

    line-height: 2.25rem;
    font-weight: 500;

    color: var(--fg-tert);

    :global(svg) {
      margin-top: 0.625rem;
      width: 1rem;
      height: 1rem;
    }

    span {
      margin-left: 0.25rem;
    }
  }

  .chips {
    @include flex($center: horz);
    padding: 0.75rem;
    padding-bottom: 0;

    @include bps(font-size, 12px, 12px, 13px);
  }

  .chip {
    display: inline-flex;
    border-radius: 0.75rem;
    padding: 0 0.75em;
    line-height: 2.25em;

    @include label();
    @include bgcolor(tert);
    @include linesd(var(--bd-main));

    &:hover {
      @include linesd(primary, 4, $ndef: false);
      @include fgcolor(primary, 5);
    }

    @include tm-dark {
      &:hover {
        @include linesd(primary, 5, $ndef: false);
        @include fgcolor(primary, 4);
      }
    }

    & + & {
      @include bps(margin-left, 0.25rem, 0.375rem);
    }
  }

  .chip-icon {
    margin-top: 0.5em;
    margin-right: 0.375em;

    > :global(svg) {
      display: block;
      width: 1.25em;
      height: 1.25em;
    }
  }

  .chip-text {
    @include clamp($width: null);
  }

  .chap {
    display: block;
    margin: 0 0.75rem;
    @include border(--bd-main, $loc: bottom);

    padding: 0.375rem 0.5rem;
    user-select: none;

    &:first-child {
      @include border(--bd-main, $loc: top);
    }

    &:nth-child(odd) {
      background: var(--bg-main);
    }
  }

  // prettier-ignore
  .chap-title {
    flex: 1;
    margin-right: 0.125rem;
    @include fgcolor(secd);
    @include clamp($width: null);

    .chap:visited & { @include fgcolor(neutral, 5); }
    .chap:hover & { @include fgcolor(primary, 5); }
  }

  .chap-text {
    display: flex;
    line-height: 1.5rem;
  }

  .chap-meta {
    @include flex($gap: 0.25rem);
    padding: 0;
    line-height: 1rem;
    margin-top: 0.25rem;
    text-transform: uppercase;

    @include ftsize(xs);
    @include fgcolor(neutral, 5);
    @include clamp($width: null);
  }

  .chap-chidx {
    @include fgcolor(tert);
    @include ftsize(xs);
  }

  .chap-icon {
    @include fgcolor(tert);
    // height: 0.8rem;
    margin-left: auto;
    font-size: 1rem;
    margin-top: -0.125rem;
  }

  .chap-bname {
    @include clamp($width: null);
  }

  .tabnav {
    display: flex;
    padding: 0.75rem;

    justify-content: space-between;
    @include border($loc: bottom);
  }
</style>
