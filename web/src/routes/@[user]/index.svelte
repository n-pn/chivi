<script context="module">
  const tabs = [
    ['all', 'Tất cả', 'asterisk'],
    ['reading', 'Đang đọc', 'eye'],
    ['completed', 'Hoàn thành', 'check-square'],
    ['dropped', 'Vứt bỏ', 'trash'],
    ['pending', 'Đọc sau', 'calendar'],
  ]

  export async function preload({ params, query }) {
    const bslug = params.book

    const res = await this.fetch(`/_users/${params.user}/tagged_books`)
    const data = await res.json()

    if (res.status == 200) {
      return { books: data, tagged: query.tag || 'all' }
    } else this.error(res.status, data.msg)
  }

  export function filter_content(books) {
    const res = {
      all: books,
      reading: [],
      completed: [],
      dropped: [],
      pending: [],
    }

    for (let book of books) res[book.tagged].push(book)

    return res
  }
</script>

<script>
  import MIcon from '$mould/MIcon.svelte'
  import Vessel from '$layout/Vessel.svelte'
  import BookList from '$reused/BookList.svelte'

  export let books = []
  export let tagged = 'all'

  $: content = filter_content(books)
</script>

<Vessel>
  <span slot="header-left" class="header-item _active">
    <MIcon class="m-icon _layers" name="layers" />
    <span class="header-text">Tủ truyện</span>
  </span>

  <div class="tabs">
    {#each tabs as [tag_type, tag_name, tag_icon]}
      <span
        class="tab"
        class:_active={tag_type == tagged}
        on:click={() => (tagged = tag_type)}>{tag_name} ({content[tag_type].length})</span>
    {/each}
  </div>

  <BookList books={content[tagged]} />
</Vessel>

<style lang="scss">
  .tabs {
    margin: 0.75rem 0;
    display: flex;
    @include border($sides: bottom);
  }

  .tab {
    line-height: 2.5rem;
    text-transform: uppercase;
    cursor: pointer;
    font-weight: 500;
    padding: 0 0.5rem;

    @include fgcolor(neutral, 6);
    @include font-size(3);

    &:hover {
      @include fgcolor(primary, 6);
    }

    &._active {
      @include border($sides: bottom, $width: 2px, $color: primary, $shade: 6);
    }
  }
</style>
