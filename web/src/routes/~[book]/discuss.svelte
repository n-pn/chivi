<script context="module">
  import Common from './_common'

  export async function preload({ params }) {
    const b_slug = params.book

    const res = await this.fetch(`/api/books/${b_slug}`)
    const data = await res.json()

    if (res.ok) return { book: data.book, mark: data.mark }
    else this.error(res.status, data.msg)
  }
</script>

<script>
  export let nvinfo
  export let nvmark = ''
</script>

<Common {...nvinfo} {nvmark} atab="threads">
  <div class="empty">Chưa hoàn thiện :(</div>
</Common>

<style lang="scss">
  .empty {
    min-height: 50vh;
    display: flex;
    align-items: center;
    justify-content: center;
    text-align: center;
    font-style: italic;
    @include font-size(4);
    @include fgcolor(neutral, 5);
  }
</style>
