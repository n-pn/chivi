<script lang="ts">
  import type { PageData } from './$types'
  export let data: PageData

  // import SIcon from '$gui/atoms/SIcon.svelte'
  const scopes = ['today', 'yesterday', 'last_7_days']
</script>

<nav class="scope-list">
  {#each scopes as scope}
    <a
      class="scope"
      class:_active={scope == data.scope}
      href="/cm/qtran-stat?scope={scope}">{scope}</a>
  {/each}
</nav>

<article class="article island md-article">
  <h1>Thống kê dịch chương</h1>

  <h2>Thống kê theo người dùng ({data.user_stats.length}):</h2>

  <section class="user-stats">
    {#each data.user_stats as stat}
      {@const user = data.user_infos[stat.viuser_id]}

      <span class="stat">
        <a class="label cv-user" data-privi={user.privi} href="/@{user.uname}"
          >{user.uname}</a>
        <span class="value">{stat.point_cost}</span>
      </span>
    {/each}
  </section>

  <h2>Thống kê theo bộ truyện ({data.book_stats.length}):</h2>

  <section class="book-stats">
    {#each data.book_stats as stat}
      {@const book = data.book_infos[stat.wninfo_id]}

      <span class="stat">
        <a class="label fg-link" href="/wn/{book.bslug}">{book.vtitle}</a>
        <span class="value">{stat.point_cost}</span>
      </span>
    {/each}
  </section>
</article>

<style lang="scss">
  .scope-list {
    display: flex;
    justify-content: center;
    margin-top: 0.75rem;
    gap: 0.5rem;
  }

  .scope {
    line-height: 1.75rem;
    text-transform: uppercase;

    font-weight: 500;
    padding: 0 0.5rem;

    @include bdradi();
    @include border();
    @include ftsize(sm);

    @include fgcolor(tert);

    &._active {
      @include fgcolor(primary, 5);
    }
  }

  article {
    margin-top: 0.75rem;

    > * + * {
      margin-top: 1rem;
    }
  }

  .user-stats {
    display: flex;
    flex-wrap: wrap;
    gap: 0.5rem;
  }

  .book-stats {
    display: grid;
    gap: 0.5rem;
    grid-template-columns: repeat(auto-fill, minmax(15rem, 1fr));
  }

  .stat {
    display: inline-flex;
    line-height: 1.75rem;

    gap: 0.25rem;
    padding: 0 0.5rem;
    @include border();
    @include bdradi($value: 2rem);
  }

  .label {
    @include clamp($width: null);
  }

  .value {
    margin-left: auto;
    // font-weight: 500;
    @include fgcolor(secd);
    font-style: italic;
  }
</style>
