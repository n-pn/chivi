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

<Shared {book} {mark} atab="overview">
  <div class="summary">
    <h2>Giới thiệu:</h2>
    {#each book.vi_intro.split('\n') as line}
      <p>{line}</p>
    {/each}
  </div>
</Shared>

<style lang="scss">
  .summary {
    p {
      margin: 0.75rem 0;
      word-wrap: break-word;
      @include fgcolor(neutral, 7);
      @include props(font-size, rem(15px), rem(16px), rem(17px));
    }
  }
</style>
