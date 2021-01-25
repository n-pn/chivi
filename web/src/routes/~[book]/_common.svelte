<script context="module">
  import { u_power, u_dname } from '$src/stores'
  import { set_nvmark, get_nvmark } from '$utils/api_calls'
  import { host_name, map_status } from '$utils/book_utils'
  import { mark_types, mark_names, mark_icons } from '$utils/constants'
</script>

<script>
  import SIcon from '$blocks/SIcon'
  import BCover from '$blocks/BCover'
  import RTime from '$blocks/RTime'

  import Vessel from '$layout/Vessel'

  import { onMount } from 'svelte'

  export let nvinfo = {}
  export let atab = 'summary'

  $: zh_title = nvinfo.btitle[0]
  $: vi_title = nvinfo.btitle[2] || nvinfo.btitle[1]

  $: vi_author = nvinfo.author[1] || nvinfo.author[0]

  $: vi_status = map_status(nvinfo.status)

  $: book_url = `https://chivi.xyz/~${nvinfo.bslug}`
  $: book_intro = nvinfo.bintro.join('').substring(0, 300)
  $: book_cover = `https://chivi.xyz/covers/${nvinfo.bcover}`
  $: updated_at = new Date(nvinfo._utime * 1000)
  $: keywords = gen_keywords()

  let nvmark = ''
  onMount(async () => {
    const [err, data] = await get_nvmark(fetch, nvinfo.bhash, $u_dname)
    if (!err) nvmark = data.nvmark
  })

  async function mark_book(new_mark) {
    nvmark = nvmark == new_mark ? '' : new_mark
    await set_nvmark(fetch, nvinfo.bhash, nvmark, $u_dname)
  }

  function gen_keywords() {
    let res = [...nvinfo.btitle, ...nvinfo.author, ...nvinfo.genres]
    res.push('Truyện tàu', 'Truyện convert', 'Truyện mạng')
    return res.join(',')
  }
</script>

<svelte:head>
  <title>{vi_title} - Chivi</title>
  <meta name="keywords" content={keywords} />
  <meta name="description" content={book_intro} />

  <meta property="og:title" content={vi_title} />
  <meta property="og:type" content="novel" />
  <meta property="og:description" content={book_intro} />
  <meta property="og:url" content={book_url} />
  <meta property="og:image" content={book_cover} />

  <meta property="og:novel:category" content={nvinfo.genres[0]} />
  <meta property="og:novel:author" content={vi_author} />
  <meta property="og:novel:book_name" content={vi_title} />
  <meta property="og:novel:read_url" content="{book_url}&tab=content" />
  <meta property="og:novel:status" content={vi_status} />
  <meta property="og:novel:update_time" content={updated_at.toISOString()} />
</svelte:head>

<Vessel>
  <a slot="header-left" href="/~{nvinfo.bslug}" class="header-item _active">
    <SIcon name="book-open" />
    <span class="header-text _title">{vi_title}</span>
  </a>

  <span slot="header-right" class="header-item _menu">
    <SIcon name={nvmark ? mark_icons[nvmark] : 'bookmark'} />
    <span class="header-text _show-md"
      >{nvmark ? mark_names[nvmark] : 'Đánh dấu'}</span>

    {#if $u_power > 0}
      <div class="header-menu">
        {#each mark_types as m_type}
          <div class="-item" on:click={() => mark_book(m_type)}>
            <SIcon name={mark_icons[m_type]} />
            <span>{mark_names[m_type]}</span>

            {#if nvmark == m_type}
              <span class="_right">
                <SIcon name="check" />
              </span>
            {/if}
          </div>
        {/each}
      </div>
    {/if}
  </span>

  <div class="main-info">
    <div class="title">
      <h1 class="-main">{vi_title}</h1>
      <h2 class="-sub">({zh_title})</h2>
    </div>

    <div class="cover">
      <BCover bhash={nvinfo.bhash} bcover={nvinfo.bcover} />
    </div>

    <section class="extra">
      <div class="line">
        <span class="stat -trim">
          <SIcon name="pen-tool" />
          <a class="link" href="/search?kw={vi_author}&type=author">
            <span class="label">{vi_author}</span>
          </a>
        </span>

        {#each nvinfo.genres as bgenre}
          <span class="stat _genre">
            <SIcon name="folder" />
            <a class="link" href="/?bgenre={bgenre}">
              <span class="label">{bgenre}</span>
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
          <span><RTime m_time={nvinfo._utime * 1000} /></span>
        </span>
      </div>

      <div class="line">
        <span class="stat">
          Đánh giá:
          <span class="label"
            >{nvinfo.voters <= 10 ? '--' : nvinfo.rating / 10}</span
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

          {#if nvinfo.yousuu !== ''}
            <a
              class="stat link _outer"
              href="https://www.yousuu.com/book/{nvinfo.yousuu}"
              rel="noopener noreferer"
              target="_blank"
              title="Đánh giá"> yousuu </a>
          {/if}
        </div>
      {/if}
    </section>
  </div>

  <div class="section">
    <header class="section-header">
      <a
        href="/~{nvinfo.bslug}"
        class="header-tab"
        class:_active={atab == 'summary'}> Tổng quan </a>

      <a
        href="/~{nvinfo.bslug}/content"
        class="header-tab"
        class:_active={atab == 'content'}> Chương tiết </a>

      <a
        href="/~{nvinfo.bslug}/discuss"
        class="header-tab"
        class:_active={atab == 'discuss'}> Thảo luận </a>
    </header>

    <div class="section-content">
      <slot />
    </div>
  </div>
</Vessel>

<style lang="scss">
  .main-info {
    padding-top: 0.75rem;
    @include flow();
  }

  .title {
    margin-bottom: 0.75rem;

    @include props(float, left, left, right);
    @include props(width, 100%, 100%, 70%, 75%);
    @include props(padding-left, 0, 0, 0.75rem);

    > .-main,
    > .-sub {
      @include fgcolor(neutral, 8);
      display: inline-block;
      font-weight: 400;
      @include props(line-height, 1.5rem, 1.75rem, 2rem);
    }

    > .-main {
      @include props(font-size, rem(20px), rem(22px), rem(22px), rem(24px));
    }

    > .-sub {
      @include props(font-size, rem(18px), rem(20px), rem(20px), rem(22px));
    }
  }

  .cover {
    float: left;
    @include props(width, 40%, 35%, 30%, 25%);
  }

  .extra {
    float: right;
    padding-left: 0.75rem;

    @include props(width, 60%, 65%, 70%, 75%);

    :global(svg) {
      margin-top: -0.125rem;
    }
  }

  .line {
    margin-bottom: 0.5rem;
    @include fgcolor(neutral, 6);
    @include flex($wrap: true);
    @include flex-gap($gap: 0, $child: ':global(*)');
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
    }
  }

  .-trim {
    max-width: 100%;
    @include truncate(null);
  }

  .label {
    font-weight: 500;
    // @include fgcolor(neutral, 8);
  }

  .section {
    background-color: #fff;

    margin: 0 -0.5rem;
    padding: 0 0.5rem;

    border-radius: 0.5rem;

    @include shadow(2);

    @include screen-min(md) {
      margin: 0.75rem 0;
      padding-left: 1rem;
      padding-right: 1rem;
      border-radius: 1rem;
    }
  }

  $section-height: 3rem;
  .section-header {
    height: $section-height;
    display: flex;
    @include border($sides: bottom, $color: neutral, $shade: 3);
  }

  .header-tab {
    height: $section-height;
    line-height: $section-height;
    width: 50%;
    font-weight: 500;
    text-align: center;
    text-transform: uppercase;

    @include font-size(2);
    @include screen-min(md) {
      @include font-size(3);
    }

    @include fgcolor(neutral, 6);
    &._active {
      @include fgcolor(primary, 6);
      @include border($sides: bottom, $color: primary, $shade: 5, $width: 2px);
    }
  }

  .section-content {
    padding: 0.75rem 0;
    display: block;
    min-height: 50vh;
  }
</style>
