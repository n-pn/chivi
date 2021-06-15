<script>
  import { mark_names, mark_icons } from '$lib/constants'
  import { logout_user } from '$api/viuser_api'
  import { u_dname, u_power, dark_mode } from '$lib/stores'

  import SIcon from '$lib/blocks/SIcon.svelte'
  import Slider from './Slider.svelte'

  export let actived = false

  async function logout() {
    $u_dname = 'Khách'
    $u_power = 0
    await logout_user(window.fetch)
  }

  let chaps = []
  $: if (actived) load_chaps(0)

  async function load_chaps(skip = 0) {
    const res = await fetch(`/api/mark-chaps?skip=${skip}`)
    if (res.ok) chaps = await res.json()
  }
</script>

<Slider bind:actived width={26}>
  <svelte:fragment slot="header-left">
    <div class="-icon">
      <SIcon name="user" />
    </div>
    <div class="-text">{$u_dname} [{$u_power}]</div>
  </svelte:fragment>

  <svelte:fragment slot="header-right">
    <button class="-btn" on:click={() => dark_mode.update((x) => !x)}>
      <SIcon name={$dark_mode ? 'sun' : 'moon'} />
    </button>

    <button class="-btn" on:click={logout}>
      <SIcon name="log-out" />
    </button>
  </svelte:fragment>

  <div class="chips">
    {#each ['reading', 'onhold', 'pending'] as mtype}
      <a href="/@{$u_dname}?bmark={mtype}" class="-chip">
        <SIcon name={mark_icons[mtype]} />
        <span class="-text">
          {mark_names[mtype]}
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
        href="/~{chap.bslug}/-{chap.uslug}-{chap.sname}-{chap.chidx}">
        <div class="-text">
          <div class="-title">{chap.title}</div>
          <span class="-chidx">{chap.chidx}</span>
        </div>

        <div class="-meta">
          <span class="-bname">{chap.bname}</span>
          <span class="-sname">{chap.sname}</span>
        </div>
      </a>
    {/each}
  </div>
</Slider>

<style lang="scss">
  @mixin label {
    font-weight: 500;
    text-transform: uppercase;
    @include fgcolor(neutral, 6);
  }

  .label {
    @include flex();
    margin: 0.25rem 0.375rem;
    padding: 0 0.5rem;

    line-height: 2.25rem;
    font-weight: 500;

    // text-transform: uppercase;
    // @include font-size(2);
    @include fgcolor(neutral, 6);

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
    display: flex;
    padding: 0.75rem;
    padding-bottom: 0;

    @include props(font-size, 12px, 12px, 13px);
  }

  .-chip {
    display: inline-flex;
    border-radius: 0.75rem;
    padding: 0 0.75em;
    background-color: #fff;
    line-height: 2.25em;

    @include label();
    @include border();

    &:hover {
      @include bdcolor(primary, 5);
      @include fgcolor(primary, 6);
    }

    > .-text {
      @include truncate(null);
    }

    > :global(svg) {
      display: inline-block;
      width: 1.25em;
      height: 1.25em;
      margin-top: 0.5em;
      margin-right: 0.375em;
    }

    & + & {
      @include props(margin-left, 0.25rem, 0.375rem);
    }
  }

  .chap {
    display: block;
    margin: 0 0.75rem;
    @include border($sides: bottom);

    padding: 0.375rem 0.5rem;
    user-select: none;

    &:first-child {
      @include border($sides: top);
    }

    &:nth-child(odd) {
      @include bgcolor(neutral, 1);
    }

    .-text {
      display: flex;
      line-height: 1.5rem;
    }

    .-meta {
      display: flex;
      padding: 0;
      line-height: 1rem;
      margin-top: 0.25rem;
      text-transform: uppercase;
      font-size: rem(12px);
      @include fgcolor(neutral, 5, 0.8);
      @include truncate(null);
    }

    .-title {
      flex: 1;
      @include fgcolor(neutral, 8);
      @include truncate(null);
    }

    &:visited .-title {
      @include fgcolor(neutral, 6, 0.6);
    }

    &:hover .-title {
      @include fgcolor(primary, 5);
    }

    .-chidx {
      margin-left: 0.125rem;
      @include fgcolor(neutral, 5, 0.6);
      @include font-size(1);

      &:after {
        content: '.';
      }
    }

    .-bname {
      flex: 1;
      @include truncate(null);
    }
  }
</style>
