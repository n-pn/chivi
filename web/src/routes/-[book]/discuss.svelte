<script context="module">
  export async function load({ context }) {
    return { props: { cvbook: context.cvbook } }
  }
</script>

<script>
  import Book from './_book.svelte'
  export let cvbook
</script>

<Book {cvbook} nvtab="discuss">
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
    @include ftsize(lg);
    color: var(--color-gray-5);
  }
</style>
