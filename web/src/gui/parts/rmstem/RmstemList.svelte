<script lang="ts" context="module">
  import { page } from '$app/stores'
  import { goto } from '$app/navigation'

  const icons = { by: 'edit', wn: 'book', lb: 'tag', sn: 'world' }

  const sorts = {
    rtime: 'Đổi mới',
    chaps: 'Số chương',
    views: 'Lượt xem',
  }
</script>

<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'

  import Footer from '$gui/sects/Footer.svelte'
  import Mpager, { Pager } from '$gui/molds/Mpager.svelte'

  import RmstemCard from './RmstemCard.svelte'

  export let items: CV.Rmstem[]
  export let pgidx = 0
  export let pgmax = 0

  export let query = { by: '', sn: '', wn: '', lb: '', bt: '' }
  export let rpath = '/rm'

  $: pager = new Pager($page.url, { pg: 1, _s: 'rtime' })
  $: _sort = pager.get('_s')

  const edit_filter = (key: string) => {
    if (query.bt) {
      query.bt += `, ${key}: ${query[key]}`
    } else {
      query.bt = `${key}: ${query[key]}`
    }

    delete query[key]
    query = query
  }

  const remove_filter = (key: string) => {
    delete query[key]
    apply_filter()
  }

  const labels = ['by', 'sn', 'wn', 'lb']

  const apply_filter = async () => {
    const filters = (query.bt || '')
      .split(',')
      .map((x) => x.trim())
      .filter(Boolean)

    let bt = ''

    for (const filter of filters) {
      const [label, ...value] = filter.split(':')
      if (labels.includes(label)) query[label] = value.join(':').trim()
      else bt += filter
    }

    query.bt = bt

    const search = Object.entries(query)
      .filter((x) => x[1])
      .map(([k, v]) => (v ? `${k}=${v}` : ''))
      .join('&')

    const url = search ? `${rpath}?${search}` : rpath
    await goto(url)
  }
</script>

<section class="section">
  <form
    class="search"
    action={rpath}
    method="GET"
    on:submit|preventDefault={apply_filter}>
    {#each labels as key}
      {#if query[key]}
        <span class="s-tag">
          <SIcon name={icons[key]} />
          <button type="button" on:click={() => edit_filter(key)}>
            <span class="trim">{query[key]}</span>
          </button>
          <button type="button" on:click={() => remove_filter(key)}>
            <SIcon name="x" />
          </button>
        </span>
      {/if}
    {/each}

    <input
      type="text"
      class="s-inp u-fg-secd"
      name="bt"
      placeholder="Tìm kiếm theo tên tiếng Trung hoặc Hán Việt bộ truyện"
      bind:value={query.bt} />
    <button class="s-btn" type="submit"><SIcon name="search" /></button>
  </form>

  <nav class="sorts">
    <span class="label _sort">Sắp xếp:</span>
    {#each Object.entries(sorts) as [value, label]}
      <a
        href={pager.gen_url({ _s: value })}
        class="m-chip _primary _sort"
        class:_active={value == _sort}>
        {label}
      </a>
    {/each}
  </nav>

  {#each items as rstem}
    <RmstemCard {rstem} {rpath} />
  {:else}
    <div class="d-empty">Danh sách trống</div>
  {/each}
</section>

<Footer>
  <Mpager {pager} {pgidx} {pgmax} />
</Footer>

<style lang="scss">
  .search {
    @include flex-cy;
    margin: 1rem 0;
    gap: 0.25rem;

    padding: 0.25rem 0.5rem;

    border-radius: 2rem;
    position: relative;
    overflow: hidden;

    @include fgcolor(main);
    @include bgcolor(main);

    @include border(--bd-soft);

    @include hover-focus {
      @include bdcolor(primary, 5);
      // box-shadow: 0 0 0 1px color(primary, 5, 5);
    }

    &:focus-within {
      @include bgcolor(tert);
      box-shadow: 0 0 0 1px color(primary, 5, 5);
    }

    :global(svg) {
      display: inline-flex;
      @include fgcolor(tert);
    }

    button {
      display: inline-flex;
      border: none;
      background-color: transparent;

      @include fgcolor(tert);
      @include ftsize(sm);

      &:hover {
        @include fgcolor(primary, 5);
      }
    }
  }

  .trim {
    max-width: 20vw;
    @include clamp($width: null);
  }

  .s-tag {
    @include flex-cy;

    padding-left: 0.5rem;
    padding-right: 0.25rem;
    border-radius: 1rem;

    @include bgcolor(neutral, 5, 1);
  }

  .s-inp {
    flex: 1;
    width: 1rem;
    display: block;
    padding-right: 1.5rem;

    border: none;
    background: transparent;

    &::placeholder {
      font-style: italic;
      @include fgcolor(tert);
    }
  }

  .s-btn {
    @include flex-ca;
    position: absolute;
    right: 0;
    top: 0;
    bottom: 0;
    margin-right: 0.5rem;

    &:hover {
      @include fgcolor(primary, 5);
    }
  }

  .section {
    margin-top: 1rem;
    @include bp-min(tl) {
      padding-left: var(--gutter);
      padding-right: var(--gutter);
    }
  }

  .sorts {
    @include flex-ca($gap: 0.5rem);
    margin-bottom: 1rem;
  }
</style>
