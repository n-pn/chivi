<script context="module">
  import Shared from './_shared'

  export async function preload({ params }) {
    const bslug = params.book

    const res = await this.fetch(`/api/books/${bslug}`)
    const data = await res.json()

    if (res.ok) return { book: data.book, mark: data.mark }
    else this.error(res.status, data.msg)
  }
</script>

<script>
  export let book
  export let mark = ''
</script>

<Shared {book} {mark} atab="threads">
  <div class="empty">Chưa hoàn thiện :(</div>
</Shared>

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
