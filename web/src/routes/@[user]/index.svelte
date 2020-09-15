<script context="module">
  const tabs = [
    ['reading', 'Đang đọc', 'eye'],
    ['completed', 'Hoàn thành', 'check-square'],
    ['onhold', 'Tạm ngưng', 'pause'],
    ['dropped', 'Vứt bỏ', 'trash'],
    ['pending', 'Đọc sau', 'calendar'],
  ]

  export async function preload({ params, query }) {
    const tagged = query.tab || 'reading'
    const res = await this.fetch(
      `/_users/${params.user}/tagged_books?tag=${tagged}`
    )
    const data = await res.json()

    if (res.status == 200) {
      return { books: data, uname: params.user, tagged }
    } else this.error(res.status, data.msg)
  }
</script>

<script>
  import MIcon from '$mould/MIcon.svelte'
  import Vessel from '$layout/Vessel.svelte'
  import BookList from '$reused/BookList.svelte'

  export let books = []
  export let uname = ''
  export let tagged = 'reading'
</script>

<Vessel>
  <span slot="header-left" class="header-item _active">
    <MIcon class="m-icon" name="layers" />
    <span class="header-text">Tủ truyện của @{uname}</span>
  </span>

  <div class="tabs">
    {#each tabs as [tag_type, tag_name, tag_icon]}
      <a
        href="/@{uname}?tab={tag_type}"
        class="tab"
        class:_active={tag_type == tagged}>{tag_name}</a>
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
