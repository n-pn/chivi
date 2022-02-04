<script context="module">
  import { page, session } from '$app/stores'
  import { invalidate } from '$app/navigation'

  import * as ubmemo_api from '$api/ubmemo_api'
  import {
    status_types,
    status_names,
    status_icons,
    status_colors,
  } from '$lib/constants.js'

  import { data as appbar } from '$sects/Appbar.svelte'

  function gen_appbar_right(nvinfo, ubmemo) {
    if (ubmemo.chidx == 0) return null
    const last_read = ubmemo_api.last_read(nvinfo, ubmemo)
    const right_opts = { kbd: '+', _text: '_show-lg' }

    return [[last_read.text, last_read.icon, last_read.href, right_opts]]
  }
</script>

<script>
  import SIcon from '$atoms/SIcon.svelte'

  import RTime from '$atoms/RTime.svelte'
  import BCover from '$atoms/BCover.svelte'
  import Gmenu from '$molds/Gmenu.svelte'

  export let nvinfo = $page.stuff.nvinfo || {}
  export let ubmemo = $page.stuff.ubmemo || {}
  export let nvtab = 'index'

  $: appbar.set({
    left: [[nvinfo.vname, 'book', `/-${nvinfo.bslug}`, null, '_title']],
    right: gen_appbar_right(nvinfo, ubmemo),
  })

  async function update_ubmemo(status) {
    if ($session.privi < 0) return
    if (status == ubmemo.status) status = 'default'
    ubmemo.status = status
    const [stt, msg] = await ubmemo_api.update_status(nvinfo.id, status)

    if (stt) return console.log(`error update book status: ${msg}`)
    else invalidate(`/api/books/${nvinfo.bslug}`)
  }
</script>

<div class="main-info">
  <div class="title">
    <h1 class="bname _main">
      <bname-vi>{nvinfo.vname}</bname-vi>
      {#if nvinfo.zname != nvinfo.vname}
        <bname-sep>/</bname-sep>
        <bname-zh>{nvinfo.zname}</bname-zh>
      {/if}
      {#if nvinfo.hname != nvinfo.vname && nvinfo.hname != nvinfo.zname}
        <bname-sep>/</bname-sep>
        <bname-vi>{nvinfo.hname}</bname-vi>
      {/if}
    </h1>
  </div>

  <div class="cover">
    <BCover bcover={nvinfo.bcover} />
  </div>

  <div class="line">
    <span class="stat -trim">
      <SIcon name="edit" />
      <a class="link" href="/books/={nvinfo.author}">
        <span class="label">{nvinfo.author}</span>
      </a>
    </span>

    <div class="bgenres">
      {#each nvinfo.genres || [] as genre, idx}
        <span class="stat _genre" class:_trim={idx > 1}>
          <a class="link" href="/books/-{genre}">
            <SIcon name="folder" />
            <span class="label">{genre}</span>
          </a>
        </span>
      {/each}
    </div>
  </div>

  <div class="line">
    <span class="stat _status">
      <SIcon name="activity" />
      <span>{nvinfo.status}</span>
    </span>

    <span class="stat _mftime">
      <SIcon name="clock" />
      <span><RTime mtime={nvinfo.mftime} /></span>
    </span>
  </div>

  <div class="line">
    <span class="stat">
      <span>Đánh giá: </span><span class="label"
        >{nvinfo.voters <= 10 ? '--' : nvinfo.rating}</span
      >/10</span>
    <span class="stat"
      >({nvinfo.voters} lượt<span class="trim">&nbsp;đánh giá</span>)</span>
  </div>

  {#if nvinfo.ys_snvid || nvinfo.pub_link}
    <div class="line">
      <span class="stat">Liên kết:</span>

      {#if nvinfo.pub_link != ''}
        <a href="books?origin={nvinfo.pub_name}"><SIcon name="search" /></a>

        <a
          class="stat link _outer"
          href={nvinfo.pub_link}
          rel="noopener noreferer"
          target="_blank"
          title="Trang nguồn">
          <span>{nvinfo.pub_name}</span>
        </a>
      {/if}

      {#if nvinfo.ys_snvid != ''}
        <a
          class="stat link _outer"
          href="https://www.yousuu.com/book/{nvinfo.ys_snvid}"
          rel="noopener noreferer"
          target="_blank"
          title="Đánh giá">
          <span>yousuu</span>
        </a>
      {/if}
    </div>
  {/if}

  <div class="line">
    <Gmenu class="navi-item" loc="bottom">
      <button
        class="m-btn _fill _{status_colors[ubmemo.status]}"
        slot="trigger">
        <SIcon name={status_icons[ubmemo.status]} />
        <span>{status_names[ubmemo.status]}</span>
      </button>

      <svelte:fragment slot="content">
        {#each status_types as status}
          <button class="-item" on:click={() => update_ubmemo(status)}>
            <SIcon name={status_icons[status]} />
            <span>{status_names[status]}</span>
            {#if status == ubmemo.status}
              <span class="_right"><SIcon name="check" /></span>
            {/if}
          </button>
        {/each}
      </svelte:fragment>
    </Gmenu>

    <a class="m-btn _primary" href="/-{nvinfo.bslug}/chaps" data-kbd="i">
      <SIcon name="list" />
      <span class="-txt _hide">Chương tiết</span>
    </a>

    <a class="m-btn" href="/dicts/{nvinfo.bhash}" data-kbd="p">
      <SIcon name="package" />
      <span class="-txt _hide">Từ điển</span>
    </a>
  </div>
</div>

<book-section>
  <header class="section-header">
    <a
      href="/-{nvinfo.bslug}"
      class="header-tab"
      class:_active={nvtab == 'index'}>
      <span>Tổng quan</span>
    </a>

    <a
      href="/-{nvinfo.bslug}/crits"
      class="header-tab"
      class:_active={nvtab == 'crits'}>
      <span>Đánh giá</span>
    </a>

    <a
      href="/-{nvinfo.bslug}/board"
      class="header-tab"
      class:_active={nvtab == 'board'}>
      <span>Thảo luận</span>
    </a>
  </header>

  <div class="section-content">
    <slot />
  </div>
</book-section>

<style lang="scss">
  .main-info {
    margin: var(--gutter) 0;
    @include flow();
  }

  .title {
    margin-bottom: var(--gutter);

    @include bps(float, left, $pl: right);
    @include bps(width, 100%, $pl: 70%, $ts: 75%);
    @include bps(padding-left, 0, $pl: var(--gutter));
  }

  .bname {
    @include fgcolor(secd);
    font-weight: 400;
    @include clamp($lines: 2);
    // prettier-ignore
    @include bps( font-size, rem(21px), rem(22px), rem(23px), rem(25px), rem(27px) );
    @include bps(line-height, 1.5rem, $pl: 1.75rem, $ts: 2rem);
  }

  bname-sep {
    @include fgcolor(mute);
    font-size: 0.85em;
    vertical-align: top;
  }

  bname-zh {
    font-size: 0.85em;
    vertical-align: top;
    // @include bps(line-height, 1.25rem, $pl: 1.5rem, $ts: 1.75rem);
  }

  .cover {
    float: left;
    @include bps(width, 40%, $pm: 35%, $pl: 30%, $ts: 25%);
  }

  .line {
    // float: right;
    padding-left: var(--gutter);

    @include bps(width, 60%, $pm: 65%, $pl: 70%, $ts: 75%);

    span :global(svg) {
      margin-top: -0.125rem;
    }

    margin-top: var(--gutter-pm);
    @include fgcolor(tert);
    @include flex($wrap: true);

    &._chap {
      @include bps(width, 100%, $tm: 75%);
      @include bps(padding-left, 0, $tm: var(--gutter));
    }
  }

  .stat {
    margin-right: 0.5rem;
  }

  .trim {
    @include bps(display, none, $tm: inline);
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

  .label._chap {
    display: block;
    width: 100%;
    // margin-top: var(--gutter-small);
    margin-bottom: 0.25rem;
  }

  book-section {
    @include bgcolor(tert);

    display: block;
    margin: 0.5rem 0;
    @include shadow(2);

    @include bp-min(tm) {
      margin: var(--gutter);

      padding-left: 1rem;
      padding-right: 1rem;
      border-radius: 1rem;
    }

    @include tm-dark {
      @include linesd(--bd-soft, $ndef: false, $inset: false);
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
    @include bp-min(tm) {
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

  .m-btn {
    margin-right: 0.5rem;

    ._hide {
      @include bps(display, none, $tm: initial);
    }
  }
</style>
