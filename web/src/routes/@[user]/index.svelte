<script context="module">
  const mark_types = ['reading', 'onhold', 'completed', 'dropped', 'pending']

  const mark_names = {
    reading: 'Đang đọc',
    onhold: 'Tạm ngưng',
    completed: 'Hoàn thành',
    dropped: 'Ngừng đọc',
    pending: 'Đọc sau',
  }

  const mark_icons = {
    reading: 'eye',
    onhold: 'pause',
    completed: 'check-square',
    dropped: 'trash',
    pending: 'calendar',
  }
  export async function preload({ params, query }) {
    const mark = query.tab || 'reading'
    const res = await this.fetch(
      `/_users/${params.user}/marked_books?mark=${mark}`
    )
    const data = await res.json()

    if (res.status == 200) {
      return { books: data, uname: params.user, mark }
    } else this.error(res.status, data.msg)
  }
</script>

<script>
  import MIcon from '$mould/MIcon.svelte'
  import Vessel from '$layout/Vessel.svelte'
  import BookList from '$reused/BookList.svelte'

  export let mark = 'reading'
  export let uname = ''
  export let books = []
</script>

<Vessel>
  <span slot="header-left" class="header-item _active">
    <MIcon class="m-icon" name="layers" />
    <span class="header-text">Tủ truyện của @{uname}</span>
  </span>

  <div class="tabs">
    {#each mark_types as type}
      <a
        href="/@{uname}?tab={type}"
        class="tab"
        class:_active={type == mark}>{mark_names[type]}</a>
    {/each}
  </div>

  <BookList {books} />
</Vessel>

<style lang="scss">
  .tabs {
    display: flex;
    margin: 0.75rem 0;
    @include border($sides: bottom);
  }

  .tab {
    line-height: 2rem;
    text-transform: uppercase;
    cursor: pointer;
    font-weight: 500;
    padding: 0 0.5rem;
    // max-width: 30vw;

    @include font-size(2);
    @include fgcolor(neutral, 6);
    @include truncate(null);

    &:hover {
      @include fgcolor(primary, 6);
    }

    &._active {
      @include border($sides: bottom, $width: 2px, $color: primary, $shade: 6);
    }
  }
</style>
