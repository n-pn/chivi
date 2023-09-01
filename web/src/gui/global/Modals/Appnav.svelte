<script context="module" lang="ts">
  const keys = [
    'author',
    'btitle',
    'genres',
    'from',
    'seed',
    'status',
    'rating',
    'voters',
  ]

  const status_values = ['Tất cả', 'Còn tiếp', 'Hoàn thành', 'Thái giám']

  type Blabel = { name: string; slug: string }
</script>

<script lang="ts">
  import { onMount } from 'svelte'
  import { page } from '$app/stores'
  import { goto } from '$app/navigation'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import Slider from '$gui/molds/Slider.svelte'

  import { bgenres } from '$lib/constants'

  export let actived = false

  let qtext = ''
  let qtype = 'btitle'

  let query = {
    author: '',
    btitle: '',
    genres: '',
    from: '',
    seed: '',
    status: 0,
    rating: 0,
    voters: 0,
  }

  type Labels = { seeds: Blabel[]; origs: Blabel[] }
  let labels: Labels = { seeds: [], origs: [] }

  onMount(async () => {
    const res = await fetch('/_db/blbls/front')
    labels = await res.json()

    const params = $page.url.searchParams
    params.forEach((val, key) => {
      if (keys.includes(key)) query[key] = val
    })
  })

  $: if (qtype == 'btitle') {
    query.btitle = qtext
    query.author = ''
  } else {
    query.btitle = ''
    query.author = qtext
  }

  function full_search() {
    const params = new URLSearchParams()

    for (const [key, val] of Object.entries(query)) {
      if (val) params.set(key, val.toString())
    }

    goto('/wn?' + params.toString())
  }

  function fast_query() {
    goto(`/wn/search?q=${qtext}&t=${qtype}`)
  }

  function clear_query() {
    qtext = ''
    qtype = 'btitle'

    for (const key in query) {
      query[key] = ['status', 'rating', 'voters'].includes(key) ? 0 : ''
    }
  }

  let full_genres = false

  const triggers = {
    status: true,
    voters: true,
    rating: true,
    genres: true,
    seed: !!query.seed,
    from: !!query.from,
  }

  let qsearch: HTMLInputElement

  const refocus_on_qsearch = () => qsearch && qsearch.focus()

  const head_navs = [
    // ['/wn', 'books', 'Thư viện'],
    ['/gd', 'messages', 'Diễn đàn'],
    ['/wn/crits', 'stars', 'Đánh giá'],
    ['/wn/lists', 'bookmarks', 'Thư đơn'],
    ['/mt/dicts', 'package', 'Từ điển'],
    ['/sp/qtran', 'bolt', 'Dịch nhanh'],
  ]
</script>

<Slider class="appnav" bind:actived _slider="left" --slider-width="22rem">
  <svelte:fragment slot="header-left">
    <a class="brand" href="/">
      <img src="/icons/chivi.svg" alt="logo" class="-icon" />
      <span>Chivi</span>
    </a>
  </svelte:fragment>

  <svelte:fragment slot="header-right">
    {#each head_navs as [href, name, tip]}
      <a {href} class="-btn" data-tip={tip} data-tip-loc="bottom"
        ><SIcon {name} /></a>
    {/each}
  </svelte:fragment>

  <header class="header">
    <div class="header-label">Tìm truyện theo bộ lọc</div>
  </header>

  <section class="content">
    <div class="searchbox">
      <input
        class="m-input _search"
        type="search"
        name="kw"
        bind:value={qtext}
        bind:this={qsearch}
        placeholder="Từ khoá" />
      <button
        class="-icon"
        type="button"
        disabled={!qtext}
        data-kbd="↵"
        on:click={fast_query}>
        <SIcon name="search" />
      </button>
    </div>

    <div class="querytype">
      <!-- svelte-ignore a11y-click-events-have-key-events -->
      <label>
        <input
          type="radio"
          value="btitle"
          bind:group={qtype}
          on:change={refocus_on_qsearch} />
        <span>Tìm theo bộ truyện</span>
      </label>

      <label>
        <input
          type="radio"
          value="author"
          bind:group={qtype}
          on:change={refocus_on_qsearch} />
        <span>Tìm theo tác giả</span>
      </label>
    </div>
  </section>

  <details class="content" bind:open={triggers.status}>
    <summary class="summary">
      <span class="type">Trạng thái: </span>
      <span class="data">{status_values[query.status]}</span>
    </summary>

    <div class="choices">
      {#each status_values as label, value}
        {@const actived = value == query.status}

        <label class="m-chip _primary" class:_active={actived}>
          <input type="radio" bind:group={query.status} {value} />
          <span class="radio-text">{label}</span>
          {#if actived}<SIcon name="check" />{/if}
        </label>
      {/each}
    </div>
  </details>

  <details class="content" bind:open={triggers.voters}>
    <summary class="summary">
      <span class="type">Lượt đánh giá: Ít nhất</span>
      <span class="data">{query.voters} lượt</span>
    </summary>

    <div class="choices">
      {#each [0, 10, 20, 50, 100] as value}
        {@const actived = value == query.voters}

        <label class="m-chip _private" class:_active={actived}>
          <input type="radio" bind:group={query.voters} {value} />
          <span class="radio-text"><SIcon name="chevron-right" />{value}</span>
          {#if actived}<SIcon name="check" />{/if}
        </label>
      {/each}
    </div>
  </details>

  <details class="content" bind:open={triggers.rating}>
    <summary class="summary">
      <span class="type">Cho điểm: Ít nhất</span>
      <span class="data">{query.rating} điểm</span>
    </summary>

    <div class="choices">
      {#each [0, 2, 4, 6, 8] as value}
        {@const actived = value == query.rating}

        <label class="m-chip _warning" class:_active={actived}>
          <input type="radio" bind:group={query.rating} {value} />
          <span class="radio-text"
            ><SIcon name="chevron-right" />{value}.0</span>
          {#if actived}<SIcon name="check" />{/if}
        </label>
      {/each}
    </div>
  </details>

  <details class="content" bind:open={triggers.genres}>
    <summary class="summary">
      <span class="type">Thể loại: </span>
      <span class="data">{query.genres || 'Tất cả'}</span>
    </summary>

    <div class="choices">
      <label class="m-chip _success" class:_active={!query.genres}>
        <input type="radio" bind:group={query.genres} value="" />
        <span class="radio-text">Tất cả</span>
        {#if !query.genres}<SIcon name="check" />{/if}
      </label>

      {#each bgenres as [name, _, main]}
        {@const actived = name == query.genres}
        {#if actived || main || full_genres}
          <label class="m-chip _success" class:_active={actived}>
            <input type="radio" bind:group={query.genres} value={name} />
            <span class="radio-text">{name}</span>
            {#if actived}<SIcon name="check" />{/if}
          </label>
        {/if}
      {/each}

      <button class="m-chip" on:click={() => (full_genres = !full_genres)}>
        <SIcon name="chevron-{full_genres ? 'left' : 'right'}" />
      </button>
    </div>
  </details>

  <details class="content" bind:open={triggers.seed}>
    <summary class="summary">
      <span class="type">Nguồn text: </span>
      <span class="data _caps" class:_caps={query.seed}
        >{query.seed || 'Tất cả'}</span>
    </summary>

    <div class="choices">
      <label class="m-chip _caps" class:_active={!query.seed}>
        <input type="radio" bind:group={query.seed} value="" />
        <span class="radio-text">Tất cả</span>
        {#if !query.seed}<SIcon name="check" />{/if}
      </label>

      {#each labels.seeds as { name, slug }}
        {@const actived = slug == query.seed}
        <label class="m-chip _caps" class:_active={actived}>
          <input type="radio" bind:group={query.seed} value={slug} />
          <span class="radio-text">{name}</span>
          {#if actived}<SIcon name="check" />{/if}
        </label>
      {/each}
    </div>
  </details>

  <details class="content" bind:open={triggers.from}>
    <summary class="summary">
      <span class="type">Trang gốc: </span>
      <span class="data" class:_caps={query.from}
        >{query.from || 'Tất cả'}</span>
    </summary>

    <div class="choices">
      <label class="m-chip _caps" class:_active={!query.from}>
        <input type="radio" bind:group={query.from} value="" />
        <span class="radio-text">Tất cả</span>
        {#if !query.from}<SIcon name="check" />{/if}
      </label>

      {#each labels.origs as { name, slug }}
        {@const actived = slug == query.from}
        <label class="m-chip _caps" class:_active={actived}>
          <input type="radio" bind:group={query.from} value={slug} />
          <span class="radio-text">{name}</span>
          {#if actived}<SIcon name="check" />{/if}
        </label>
      {/each}
    </div>
  </details>

  <footer class="action">
    <button class="m-btn" on:click={clear_query}>
      <span>Xoá lọc</span>
      <SIcon name="eraser" />
    </button>

    <button class="m-btn _fill _primary" on:click={full_search}>
      <span>Lọc truyện</span>
      <SIcon name="filter" />
    </button>
  </footer>
</Slider>

<style lang="scss">
  @mixin label {
    font-weight: 500;
    text-transform: uppercase;
    @include fgcolor(secd);
  }

  .brand {
    display: flex;
    flex: 1;
    // padding: 0.25rem 0;
    > img {
      margin-top: 0.375rem;
      margin-right: 0.5rem;
      display: block;
      width: 1.5rem;
      height: 1.5rem;
    }

    > span {
      @include label();
      @include ftsize(lg);
      line-height: 2.375rem;
      letter-spacing: 0.04rem;
    }

    .-icon {
      margin-left: 0.25rem;
    }
  }

  .content {
    margin-top: 0.5rem;
    padding: 0 0.75rem;
  }

  .summary {
    font-weight: 500;
    line-height: 2rem;
    margin-bottom: 0.25rem;

    .type {
      @include fgcolor(tert);
    }
  }

  .choices {
    display: flex;
    flex-wrap: wrap;
    gap: 0.25rem;
  }

  .data._caps {
    text-transform: uppercase;
    font-size: rem(13px);
  }

  label.m-chip {
    height: 1.75rem;
    line-height: 1.75rem;
    cursor: pointer;
  }

  .radio-text {
    :global(svg) {
      margin-top: -0.125rem;
    }
  }

  .m-chip > input {
    display: none;
  }

  .searchbox {
    display: block;
    width: 100%;
    position: relative;

    > input {
      display: block;
      width: 100%;
      padding: 0.375rem 0.75rem;

      border: none;
      outline: none;
      border-radius: 1rem;

      @include fgcolor(main);
      @include bgcolor(main);
      @include linesd(--bd-main);

      &:focus {
        @include linesd(primary, 5, $width: 2px, $ndef: false);
      }

      &:hover,
      &:focus {
        @include bgcolor(bg-secd);
      }

      &::placeholder {
        font-style: italic;
        font-size: rem(15px);
        color: var(--fg-tert);
      }
    }

    > .-icon {
      position: absolute;
      right: 0.5rem;
      top: 0;
      padding: 0.375rem;
      margin: 0;
      background: none;
      @include fgcolor(neutral, 5);

      :global(svg) {
        width: 1rem;
        height: 1rem;
      }
    }

    > button {
      z-index: 99;
      &:hover,
      &:focus {
        @include fgcolor(primary, 5);
      }
    }
  }

  .header {
    margin-top: 0.5rem;
  }

  .header-label {
    display: block;
    // text-align: center;
    font-weight: 500;
    margin: 0 0.75rem;
    @include ftsize(lg);
  }

  .querytype {
    display: flex;
    gap: 0.5rem;
    justify-content: center;
    margin-top: 0.25rem;
    @include fgcolor(secd);
    font-size: rem(15px);
  }

  footer {
    margin: 0.75rem;
    padding-top: 0.75rem;
    text-align: center;
    @include border($loc: top);
  }
</style>
