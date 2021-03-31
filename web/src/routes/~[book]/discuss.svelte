<script context="module">
  import { get_nvinfo } from '$api/nvinfo_api'

  export async function preload({ params }) {
    const [err, data] = await get_nvinfo(this.fetch, params.book)
    if (err) this.error(err, data)
    else return { nvinfo: data }
  }
</script>

<script>
  import Book from './_book.svelte'
  export let nvinfo
</script>

<Book {nvinfo} nvtab="discuss">
  <div class="empty">Chưa hoàn thiện :(</div>
</Book>

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
