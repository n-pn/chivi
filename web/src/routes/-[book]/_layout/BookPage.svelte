<script context="module">
  import { session } from '$app/stores.js'
  import { invalidate } from '$app/navigation'

  import { put_fetch } from '$api/_api_call'
  import { host_name, map_status } from '$utils/book_utils.js'
  import { status_types, status_names, status_icons } from '$lib/constants.js'
</script>

<script>
  import SIcon from '$atoms/SIcon.svelte'
  import RTime from '$atoms/RTime.svelte'
  import BCover from '$atoms/BCover.svelte'
  import Vessel from '$sects/Vessel.svelte'

  export let cvbook
  export let ubmemo
  export let nvtab = 'index'

  $: vi_status = map_status(cvbook.status)
  $: book_intro = cvbook.bintro.join('').substring(0, 300)
  $: updated_at = new Date(cvbook.update)

  $: memo_status = ubmemo.status || 'default'

  async function change_status(status) {
    if ($session.privi < 0) return
    if (status == ubmemo.status) status = 'default'

    const url = `/api/_self/books/${cvbook.id}/status`
    const [stt, msg] = await put_fetch(fetch, url, { status })
    if (stt) return console.log(`error update book status: ${msg}`)
    invalidate(`/api/books/${cvbook.bslug}`)
  }

  function gen_keywords(cvbook) {
    // prettier-ignore
    let res = [
      cvbook.btitle_zh, cvbook.btitle_vi, cvbook.btitle_hv,
      cvbook.author_zh, cvbook.author_vi, ...cvbook.genres,
      'Truyện tàu', 'Truyện convert', 'Truyện mạng' ]
    return res.join(',')
  }
</script>

<!-- prettier-ignore -->
<svelte:head>
  <title>{cvbook.btitle_vi} - Chivi</title>
  <meta name="keywords" content={gen_keywords(cvbook)} />
  <meta name="description" content={book_intro} />

  <meta property="og:title" content={cvbook.btitle_vi} />
  <meta property="og:type" content="novel" />
  <meta property="og:description" content={book_intro} />
  <meta property="og:url" content="https://chivi.xyz/-{cvbook.bslug}" />
  <meta property="og:image" content="https://chivi.xyz/covers/{cvbook.bcover}" />

  <meta property="og:novel:category" content={cvbook.genres[0]} />
  <meta property="og:novel:author" content={cvbook.author_vi} />
  <meta property="og:novel:book_name" content={cvbook.btitle_vi} />
  <meta property="og:novel:status" content={vi_status} />
  <meta property="og:novel:update_time" content={updated_at.toISOString()} />
</svelte:head>

<Vessel>
  <a slot="header-left" href="/-{cvbook.bslug}" class="header-item _active">
    <SIcon name="book" />
    <span class="header-text _title">{cvbook.btitle_vi}</span>
  </a>

  <svelte:fragment slot="header-right">
    {#if $session.privi > 0}
      <div class="header-item _menu" class:_disable={$session.privi < 0}>
        <SIcon name={status_icons[memo_status]} />

        <span class="header-text _show-md">{status_names[memo_status]}</span>

        <div class="header-menu">
          {#each status_types as status}
            <div class="-item" on:click={() => change_status(status)}>
              <SIcon name={status_icons[status]} />
              <span>{status_names[status]}</span>

              {#if memo_status == status}
                <span class="_right">
                  <SIcon name="check" />
                </span>
              {/if}
            </div>
          {/each}
        </div>
      </div>
    {/if}

    {#if ubmemo.chidx > 0}
      <a
        class="header-item"
        href="/-{cvbook.bslug}/-{ubmemo.sname}/-{ubmemo.uslug}-{ubmemo.chidx}">
        <SIcon name={ubmemo.locked ? 'pinned' : 'player-play'} />
        <span class="header-text _show-md"
          >{ubmemo.chidx == 1 ? 'Đọc thử' : 'Đọc tiếp'}</span>
      </a>
    {:else}
      <div class="header-item _disable" title="Chưa có chương tiết">
        <SIcon name="player-play" />
        <span class="header-text _show-md">Đọc thử</span>
      </div>
    {/if}
  </svelte:fragment>

  <div class="main-info">
    <div class="title">
      <h1 class="-main">{cvbook.btitle_vi}</h1>
      <h2 class="-sub">({cvbook.btitle_zh})</h2>
    </div>

    <div class="cover">
      <BCover bcover={cvbook.bcover} />
    </div>

    <section class="extra">
      <div class="line">
        <span class="stat -trim">
          <SIcon name="edit" />
          <a
            class="link"
            href="/search?q={encodeURIComponent(cvbook.author_vi)}&t=author">
            <span class="label">{cvbook.author_vi}</span>
          </a>
        </span>

        {#each cvbook.genres as genre}
          <span class="stat _genre">
            <SIcon name="folder" />
            <a class="link" href="/?genre={genre}">
              <span class="label">{genre}</span>
            </a>
          </span>
        {/each}
      </div>

      <div class="line">
        <span class="stat _status">
          <SIcon name="activity" />
          <span>{vi_status}</span>
        </span>

        <span class="stat _mftime">
          <SIcon name="clock" />
          <span><RTime mtime={cvbook.update} /></span>
        </span>
      </div>

      <div class="line">
        <span class="stat">
          Đánh giá:
          <span class="label">{cvbook.voters <= 10 ? '--' : cvbook.rating}</span
          >/10
        </span>
        <span class="stat">({cvbook.voters} lượt đánh giá)</span>
      </div>

      {#if cvbook.yousuu || cvbook.origin}
        <div class="line">
          <span class="stat">Liên kết:</span>

          {#if cvbook.origin != ''}
            <a
              class="stat link _outer"
              href={cvbook.origin}
              rel="noopener noreferer"
              target="_blank"
              title="Trang nguồn">
              {host_name(cvbook.origin)}
            </a>
          {/if}

          {#if cvbook.yousuu != ''}
            <a
              class="stat link _outer"
              href="https://www.yousuu.com/book/{cvbook.yousuu}"
              rel="noopener noreferer"
              target="_blank"
              title="Đánh giá">
              yousuu
            </a>
          {/if}
        </div>
      {/if}
    </section>
  </div>

  <div class="section">
    <header class="section-header">
      <a
        href="/-{cvbook.bslug}"
        class="header-tab"
        class:_active={nvtab == 'index'}>
        Tổng quan
      </a>

      <a
        href="/-{cvbook.bslug}/chaps"
        class="header-tab"
        class:_active={nvtab == 'chaps'}>
        Chương tiết
      </a>

      <a
        href="/-{cvbook.bslug}/board"
        class="header-tab"
        class:_active={nvtab == 'board'}>
        Thảo luận
      </a>
    </header>

    <div class="section-content">
      <slot />
    </div>
  </div>
</Vessel>

<style lang="scss">
  .main-info {
    padding-top: var(--gutter);
    @include flow();
  }

  .title {
    margin-bottom: 0.75rem;

    @include fgcolor(secd);
    @include bps(float, left, $md: right);
    @include bps(width, 100%, $md: 70%, $lg: 75%);
    @include bps(padding-left, 0, $md: 0.75rem);
    @include bps(line-height, 1.5rem, $md: 1.75rem, $lg: 2rem);

    > .-main,
    > .-sub {
      font-weight: 400;
      display: inline-block;
    }

    > .-main {
      @include bps(
        font-size,
        rem(20px),
        rem(21px),
        rem(22px),
        rem(24px),
        rem(26px)
      );
    }

    > .-sub {
      @include bps(
        font-size,
        rem(18px),
        rem(19px),
        rem(20px),
        rem(22px),
        rem(24px)
      );
    }
  }

  .cover {
    float: left;
    @include bps(width, 40%, 35%, 30%, 25%);
  }

  .extra {
    float: right;
    padding-left: 0.75rem;

    @include bps(width, 60%, 65%, 70%, 75%);

    :global(svg) {
      margin-top: -0.125rem;
    }
  }

  .line {
    margin-bottom: var(--gutter-sm);
    @include fgcolor(tert);
    @include flex($wrap: true);
  }

  .stat {
    margin-right: 0.5rem;
  }

  .link {
    // font-weight: 500;
    color: inherit;
    // @include fgcolor(primary, 7);

    &._outer {
      text-transform: capitalize;
    }

    &._outer,
    &:hover {
      @include fgcolor(primary, 6);

      @include tm-dark {
        @include fgcolor(primary, 4);
      }
    }
  }

  .-trim {
    max-width: 100%;
    @include clamp($width: null);
  }

  .label {
    font-weight: 500;
    // @include fgcolor(neutral, 8);
  }

  .section {
    @include bgcolor(tert);

    margin: 0 -0.5rem;
    padding: 0 0.5rem;

    border-radius: 0.5rem;

    @include shadow(2);

    @include bp-min(md) {
      margin: 0.75rem 0;
      padding-left: 1rem;
      padding-right: 1rem;
      border-radius: 1rem;
    }
  }

  $section-height: 3rem;
  .section-header {
    display: flex;
    height: $section-height;
    @include border(--bd-main, $loc: bottom);

    @include tm-dark {
      @include bdcolor(neutral, 6);
    }
  }

  .header-tab {
    height: $section-height;
    line-height: $section-height;
    width: 50%;
    font-weight: 500;
    text-align: center;
    text-transform: uppercase;

    @include ftsize(sm);
    @include bp-min(md) {
      @include ftsize(md);
    }

    @include fgcolor(neutral, 6);

    &._active {
      @include fgcolor(primary, 6);
      @include border(primary, 5, $width: 2px, $loc: bottom);
    }

    @include tm-dark {
      @include fgcolor(neutral, 4);

      &._active {
        @include fgcolor(primary, 4);
      }
    }
  }

  .section-content {
    padding: 0.75rem 0;
    display: block;
    min-height: 50vh;
  }
</style>
