<script context="module">
  import { api_call, put_fetch } from '$api/_api_call'
  import { session } from '$app/stores.js'
  import { host_name, map_status } from '$utils/book_utils.js'
  import { mark_types, mark_names, mark_icons } from '$lib/constants.js'
  import { onMount } from 'svelte'
</script>

<script>
  import SIcon from '$atoms/SIcon.svelte'
  import RTime from '$atoms/RTime.svelte'
  import BCover from '$atoms/BCover.svelte'
  import Aditem from '$molds/Aditem.svelte'
  import Vessel from '$sects/Vessel.svelte'

  export let nvinfo = {}
  export let nvtab = 'index'

  $: vi_status = map_status(nvinfo.status)
  $: book_intro = nvinfo.bintro.join('').substring(0, 300)
  $: updated_at = new Date(nvinfo.update)

  let bmark = ''
  onMount(async () => {
    const [err, data] = await api_call(fetch, `ubmarks/${nvinfo.bhash}`)
    if (!err) bmark = data.bmark
  })

  async function change_status(new_mark) {
    if ($session.privi < 0) return
    bmark = bmark == new_mark ? 'default' : new_mark

    const url = `/api/_self/library/${nvinfo.id}`
    const [stt, msg] = await put_fetch(fetch, url, { status: bmark })
    if (stt) console.log(`error update book status: ${msg}`)
  }

  function gen_keywords(nvinfo) {
    // prettier-ignore
    let res = [
      nvinfo.btitle_zh, nvinfo.btitle_vi, nvinfo.btitle_hv,
      nvinfo.author_zh, nvinfo.author_vi, ...nvinfo.genres,
      'Truyện tàu', 'Truyện convert', 'Truyện mạng' ]
    return res.join(',')
  }
</script>

<!-- prettier-ignore -->
<svelte:head>
  <title>{nvinfo.btitle_vi} - Chivi</title>
  <meta name="keywords" content={gen_keywords(nvinfo)} />
  <meta name="description" content={book_intro} />

  <meta property="og:title" content={nvinfo.btitle_vi} />
  <meta property="og:type" content="novel" />
  <meta property="og:description" content={book_intro} />
  <meta property="og:url" content="https://chivi.xyz/-{nvinfo.bslug}" />
  <meta property="og:image" content="https://chivi.xyz/covers/{nvinfo.bcover}" />

  <meta property="og:novel:category" content={nvinfo.genres[0]} />
  <meta property="og:novel:author" content={nvinfo.author_vi} />
  <meta property="og:novel:book_name" content={nvinfo.btitle_vi} />
  <meta property="og:novel:status" content={vi_status} />
  <meta property="og:novel:update_time" content={updated_at.toISOString()} />
</svelte:head>

<Vessel>
  <a slot="header-left" href="/-{nvinfo.bslug}" class="header-item _active">
    <SIcon name="book" />
    <span class="header-text _title">{nvinfo.btitle_vi}</span>
  </a>

  <svelte:fragment slot="header-right">
    <a class="header-item" href="/dicts/{nvinfo.bhash}">
      <SIcon name="package" />
      <span class="header-text _show-md">Từ điển</span>
    </a>
    {#if $session.privi > 0}
      <div class="header-item _menu" class:_disable={$session.privi < 0}>
        <SIcon
          name={bmark && bmark != 'default' ? mark_icons[bmark] : 'bookmark'} />

        <span class="header-text _show-md"
          >{bmark && bmark != 'default' ? mark_names[bmark] : 'Đánh dấu'}</span>

        <div class="header-menu">
          {#each mark_types as mtype}
            <div class="-item" on:click={() => change_status(mtype)}>
              <SIcon name={mark_icons[mtype]} />
              <span>{mark_names[mtype]}</span>

              {#if bmark == mtype}
                <span class="_right">
                  <SIcon name="check" />
                </span>
              {/if}
            </div>
          {/each}
        </div>
      </div>
    {/if}
  </svelte:fragment>

  <div class="main-info">
    <div class="title">
      <h1 class="-main">{nvinfo.btitle_vi}</h1>
      <h2 class="-sub">({nvinfo.btitle_zh})</h2>
    </div>

    <div class="cover">
      <BCover bcover={nvinfo.bcover} />
    </div>

    <section class="extra">
      <div class="line">
        <span class="stat -trim">
          <SIcon name="edit" />
          <a
            class="link"
            href="/search?q={encodeURIComponent(nvinfo.author_vi)}&t=author">
            <span class="label">{nvinfo.author_vi}</span>
          </a>
        </span>

        {#each nvinfo.genres as genre}
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
          <span><RTime mtime={nvinfo.update} /></span>
        </span>
      </div>

      <div class="line">
        <span class="stat">
          Đánh giá:
          <span class="label">{nvinfo.voters <= 10 ? '--' : nvinfo.rating}</span
          >/10
        </span>
        <span class="stat">({nvinfo.voters} lượt đánh giá)</span>
      </div>

      {#if nvinfo.yousuu || nvinfo.origin}
        <div class="line">
          <span class="stat">Liên kết:</span>

          {#if nvinfo.origin != ''}
            <a
              class="stat link _outer"
              href={nvinfo.origin}
              rel="noopener noreferer"
              target="_blank"
              title="Trang nguồn">
              {host_name(nvinfo.origin)}
            </a>
          {/if}

          {#if nvinfo.yousuu != ''}
            <a
              class="stat link _outer"
              href="https://www.yousuu.com/book/{nvinfo.yousuu}"
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

  {#if $session.privi < 2}
    <Aditem type="banner" />
  {/if}

  <div class="section">
    <header class="section-header">
      <a
        href="/-{nvinfo.bslug}"
        class="header-tab"
        class:_active={nvtab == 'index'}>
        Tổng quan
      </a>

      <a
        href="/-{nvinfo.bslug}/chaps"
        class="header-tab"
        class:_active={nvtab == 'chaps'}>
        Chương tiết
      </a>

      <a
        href="/-{nvinfo.bslug}/discuss"
        class="header-tab"
        class:_active={nvtab == 'discuss'}>
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
