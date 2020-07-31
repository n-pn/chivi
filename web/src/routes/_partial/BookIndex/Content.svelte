<script context="module">
  export async function load_chaps(api, bslug, sname, mode = 0) {
    const url = `/_chaps/${bslug}/${sname}?mode=${mode}`

    try {
      const res = await api(url)
      const data = await res.json()
      return data
    } catch (err) {
      throw err.message
    }
  }

  export function paginate(chaps, focus, limit = 50, desc = false) {
    let offset = (focus - 1) * limit
    if (offset < 0) offset = 0
    if (!desc) return chaps.slice(offset, offset + limit)

    const from = chaps.length - 1 - offset
    let down = from - limit + 1
    if (down < 0) down = 0

    const output = []
    for (let i = from; i >= down; i--) output.push(chaps[i])
    return output
  }

  export function paging_url(slug, seed, page = 1) {
    return `/~${slug}?tab=content&seed=${seed}&page=${page}`
  }
</script>

<script>
  import MIcon from '$mould/MIcon.svelte'
  import relative_time from '$utils/relative_time'

  export let book
  export let seed
  export let mode = 0
  export let page = 0
  export let desc = true

  let chlist = []
  $: if (mode > 0) chlist = load_chaps(fetch, book.slug, seed, 0)

  let _loading = false
</script>

{#if book.seed_names.length > 0}
  <div class="sources">
    <div class="-left">
      <div class="-hint">Nguồn:</div>

      <div class="seed-menu">
        <div class="-text">
          <span class="-label ">{seed}</span>
          <span class="-count ">({chlist.length} chương)</span>
        </div>

        <div class="-menu">
          {#each book.seed_names as name}
            <a
              class="-item"
              class:_active={seed === name}
              href="/~{book.slug}?tab=content&seed={name}"
              on:click|preventDefault={() => (seed = name)}
              rel="nofollow">
              <span class="-name">{name}</span>
              <span class="-time">
                ({relative_time(book.seed_mftimes[name])})
              </span>
            </a>
          {/each}
        </div>
      </div>

    </div>

    <div class="-right">
      <button class="m-button _text" class:_loading on:click={() => (mode = 1)}>
        {#if _loading}
          <MIcon class="m-icon" name="loader" />
        {:else}
          <MIcon class="m-icon" name="clock" />
        {/if}
        <span>{relative_time(book.seed_mftimes[seed])}</span>
      </button>

      <button class="m-button _text" on:click={() => (desc = !desc)}>
        {#if desc}
          <MIcon class="m-icon" name="arrow-down" />
        {:else}
          <MIcon class="m-icon" name="arrow-up" />
        {/if}
        <span class="-hide">Sắp xếp</span>
      </button>
    </div>

  </div>

  <ChapList
    bslug={book.slug}
    sname={seed}
    chaps={chlist}
    focus={page}
    reverse={desc} />
{:else}
  <div class="empty">Không có nội dung</div>
{/if}
