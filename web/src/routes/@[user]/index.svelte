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
    const user = params.user
    const mark = query.mark || 'reading'
    const page = query.page || '1'

    const url = `/_users/${user}/marked_books?mark=${mark}&page=${page}`
    const res = await this.fetch(url)
    const data = await res.json()

    if (data._stt == 'err') return this.error(res.status, data._msg)

    return {
      mark,
      page,
      uname: params.user,
      books: data.books,
      total: data.total,
    }
  }
</script>

<script>
  import MIcon from '$mould/MIcon.svelte'
  import Vessel from '$layout/Vessel.svelte'
  import BookList from '$reused/BookList.svelte'

  export let mark = 'reading'
  export let page = ''
  export let uname = ''

  export let books = []
  export let total = 0

  $: page_max = Math.floor((total - 1) / 20) + 1
</script>

<Vessel>
  <span slot="header-left" class="header-item _active">
    <MIcon class="m-icon" name="layers" />
    <span class="header-text">Tủ truyện của @{uname}</span>
  </span>

  <div class="tabs">
    {#each mark_types as type}
      <a
        href="/@{uname}?mark={type}"
        class="tab"
        class:_active={type == mark}>{mark_names[type]}</a>
    {/each}
  </div>

  <BookList {books} />

  <div class="pagi">
    <a
      class="page m-button _line"
      class:_disable={page == 1}
      href="/@{uname}?mark={mark}&page={+page - 1}">
      <MIcon class="m-icon" name="chevron-left" />
      <span>Trước</span>
    </a>

    <div class="page m-button _line _primary _disable"><span>{page}</span></div>

    <a
      class="page m-button _solid _primary"
      class:_disable={page == page_max}
      href="/@{uname}?mark={mark}&page={+page + 1}">
      <span>Kế tiếp</span>
      <MIcon class="m-icon" name="chevron-right" />
    </a>
  </div>
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

  .pagi {
    margin: 0.75rem 0;
    @include flex($gap: 0.375rem);
    justify-content: center;
  }

  .page {
    display: inline-flex;
    > span {
      margin-top: rem(1px);
    }
  }
</style>
