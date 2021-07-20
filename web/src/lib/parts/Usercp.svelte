<script>
  import { session } from '$app/stores'
  import { mark_names, mark_icons } from '$lib/constants'

  import SIcon from '$atoms/SIcon.svelte'
  import Slider from '$molds/Slider.svelte'

  export let actived = false

  async function logout() {
    $session = { uname: 'Khách', privi: -1 }
    await fetch('/api/user/logout')
  }

  let chaps = []
  $: if (actived) load_chaps(0)

  async function load_chaps(skip = 0) {
    const res = await fetch(`/api/mark-chaps?skip=${skip}`)
    if (res.ok) chaps = await res.json()
  }

  let wtheme = $session.wtheme
  let tlmode = $session.tlmode
  $: update_setting(wtheme, tlmode)

  async function update_setting(wtheme, tlmode) {
    if (wtheme == $session.wtheme && tlmode == $session.tlmode) return
    console.log('update!')

    const res = await fetch('/api/user/setting', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ wtheme, tlmode }),
    })

    if (res.ok) $session = await res.json()
    else console.log('Error: ' + (await res.text()))
  }

  const tlmodes = ['Cơ bản', 'Tiêu chuẩn', 'Nâng cao']
</script>

<Slider bind:actived _rwidth={26}>
  <svelte:fragment slot="header-left">
    <div class="-icon">
      <SIcon name="user" />
    </div>
    <div class="-text">{$session.uname} [{$session.privi}]</div>
  </svelte:fragment>

  <svelte:fragment slot="header-right">
    <button
      class="-btn"
      data-kbd="t"
      on:click={() => (wtheme = wtheme == 'dark' ? 'light' : 'dark')}>
      <SIcon name={wtheme == 'dark' ? 'sun' : 'moon'} />
    </button>

    <button class="-btn" on:click={logout}>
      <SIcon name="log-out" />
    </button>
  </svelte:fragment>

  <div class="tlmode">
    <div class="-radio">
      <span class="-label">Chế độ dịch:</span>
      {#each tlmodes as label, value}
        <label class="m-radio">
          <input type="radio" name="tlmode" {value} bind:group={tlmode} />
          <span>{label}</span>
        </label>
      {/each}
    </div>

    <div class="-explain">
      {#if $session.tlmode == 0}
        Không áp dụng các luật ngữ pháp. Các từ "đích", "trứ", "liễu" sẽ lờ đi
        trong câu văn.
      {:else if $session.tlmode == 1}
        Áp dụng một số luật ngữ pháp cơ bản, phần lớn chính xác. <strong
          >(Khuyến khích)</strong>
      {:else}
        Sử dụng đầy đủ các luật ngữ pháp đang được hỗ trợ, đảo vị trí của các từ
        trong câu cho thuần việt. <em>(Đang thử nghiệm)</em>
      {/if}
    </div>
  </div>

  <div class="chips">
    {#each ['reading', 'onhold', 'pending'] as mtype}
      <a href="/@{$session.uname}?bmark={mtype}" class="-chip">
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

    @include fluid(font-size, 12px, 12px, 13px);
  }

  .-chip {
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

    > .-text {
      @include clamp($width: null);
    }

    > :global(svg) {
      display: inline-block;
      width: 1.25em;
      height: 1.25em;
      margin-top: 0.5em;
      margin-right: 0.375em;
    }

    & + & {
      @include fluid(margin-left, 0.25rem, 0.375rem);
    }
  }

  .tlmode {
    padding: 0.5rem 0.75rem;
    @include border(--bd-main, $sides: bottom);
    > .-radio {
      line-height: 2rem;
      @include flex($center: none, $gap: 0.5rem);
      @include fluid(font-size, rem(14px), rem(15px), rem(16px));
    }

    .-label {
      font-weight: 500;
      @include fgcolor(secd);
    }

    > .-explain {
      @include fgcolor(tert);
      @include ftsize(sm);
      line-height: 1.25rem;
    }
  }

  .chap {
    display: block;
    margin: 0 0.75rem;
    @include border(--bd-main, $sides: bottom);

    padding: 0.375rem 0.5rem;
    user-select: none;

    &:first-child {
      @include border(--bd-main, $sides: top);
    }

    &:nth-child(odd) {
      background: var(--bg-main);
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

      @include ftsize(xs);
      @include fgcolor(neutral, 5);
      @include clamp($width: null);
    }

    .-title {
      flex: 1;
      @include fgcolor(secd);
      @include clamp($width: null);
    }

    &:visited .-title {
      @include fgcolor(neutral, 5);
    }

    &:hover .-title {
      @include fgcolor(primary, 5);
    }

    .-chidx {
      margin-left: 0.125rem;
      @include fgcolor(tert);
      @include ftsize(xs);

      &:after {
        content: '.';
      }
    }

    .-bname {
      flex: 1;
      @include clamp($width: null);
    }
  }
</style>
