<script lang="ts" context="module">
  import { page } from '$app/stores'
  import { goto } from '$app/navigation'

  const icons = { vu: 'at', au: 'edit', wn: 'book', lb: 'tag' }

  const sorts = {
    ctime: 'Vừa thêm',
    mtime: 'Đổi mới',
    chaps: 'Số chương',
    views: 'Lượt xem',
  }
</script>

<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'

  import Footer from '$gui/sects/Footer.svelte'
  import Mpager, { Pager } from '$gui/molds/Mpager.svelte'

  import UpstemCard from './UpstemCard.svelte'

  export let items: CV.Upstem[]
  export let pgidx = 0
  export let pgmax = 0

  export let query = { vu: '', au: '', wn: '', lb: '', kw: '' }
  export let upath = '/up'

  $: pager = new Pager($page.url, { pg: 1, _s: 'ctime' })
  $: _sort = pager.get('_s')

  const edit_filter = (key: string) => {
    if (query.kw) {
      query.kw += `, ${key}: ${query[key]}`
    } else {
      query.kw = `${key}: ${query[key]}`
    }

    delete query[key]
    query = query
  }

  const remove_filter = (key: string) => {
    delete query[key]
    apply_filter()
  }

  const labels = ['vu', 'au', 'wn', 'lb']

  const apply_filter = async () => {
    const filters = (query.kw || '')
      .split(',')
      .map((x) => x.trim())
      .filter(Boolean)

    let kw = ''

    for (const filter of filters) {
      const [label, ...value] = filter.split(':')
      if (labels.includes(label)) query[label] = value.join(':').trim()
      else kw += filter + ','
    }

    query.kw = kw

    const search = Object.entries(query)
      .filter((x) => x[1])
      .map(([k, v]) => (v ? `${k}=${v}` : ''))
      .join('&')

    const url = search ? `${upath}?${search}` : upath
    await goto(url)
  }
</script>

<section class="section">
  <form
    class="search"
    action={upath}
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
      name="kw"
      placeholder="Tìm kiếm theo tựa tiếng Trung hoặc Hán Việt"
      bind:value={query.kw} />
    <button class="s-btn u-fz-lg" type="submit"><SIcon name="search" /></button>
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

  {#each items as ustem}
    <UpstemCard {ustem} {upath} />
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

    padding: 0.25rem;
    padding-right: 0.5rem;
    border-radius: 2rem;

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
        @include fgcolor(primary);
      }
    }
  }

  .trim {
    max-width: 30vw;
    @include clamp($width: null);
  }

  .s-tag {
    @include flex-cy;

    margin-left: 0.75rem;
    padding-left: 0.375rem;
    border-radius: 0.25rem;

    @include bgcolor(neutral, 5, 1);
  }

  .s-inp {
    flex: 1;
    padding: 0 0.75rem;

    border: none;
    background: transparent;

    &::placeholder {
      font-style: italic;
      @include fgcolor(tert);
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
