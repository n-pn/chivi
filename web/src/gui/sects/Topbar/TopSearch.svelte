<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'
  export let query = ''
</script>

<form class="query" action="/books/query" method="get">
  <input type="search" name="q" placeholder="Tìm truyện" value={query} />
  <SIcon name="search" />
</form>

<style lang="scss">
  $height: 2.25rem;

  .query {
    position: relative;
    padding: 0;
    flex: 1;
    max-width: 13rem;
    cursor: text;

    --radi: 1.125rem;
    border-radius: var(--radi);

    > input {
      color: inherit;
      padding: 0 1rem;
      display: block;
      height: $height;
      // font-weight: 500;
      width: 100%;
      border: none;
      outline: none;
      border-radius: var(--radi);

      @include bgcolor(primary, 7);

      &::placeholder {
        color: var(--color-gray-1);
      }
    }

    > :global(svg) {
      position: absolute;
      // display: flex;
      padding: 0;
      margin: 0;
      right: 0.875rem;
      top: 0.625rem;
      width: 1.125rem;
      height: 1.125rem;
      color: var(--color-gray-4);
    }
  }
</style>
