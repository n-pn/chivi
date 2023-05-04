<script lang="ts">
  import { page } from '$app/stores'

  import type { PageData } from './$types'
  export let data: PageData
  import { rel_time_vp } from '$utils/time_utils'

  import Mpager, { Pager } from '$gui/molds/Mpager.svelte'

  $: pager = new Pager($page.url, { pg: 1, tl: '' })
</script>

<article class="article">
  <h1>Thông báo <span class="u-badge">{data.total}</span></h1>

  <div class="notifs">
    {#each data.notifs as notif}
      <div class="notif" class:_fresh={!notif.reached_at}>
        {@html notif.content}
        <footer class="notif-foot">
          <time>{rel_time_vp(notif.created_at)}</time>
        </footer>
      </div>
    {/each}
  </div>

  <footer class="pagi">
    <Mpager {pager} pgidx={data.pgidx} pgmax={data.pgmax} />
  </footer>
</article>

<style lang="scss">
  article {
    margin-top: 0.75rem;
  }

  .notifs {
    margin-top: 1rem;
  }

  .notif {
    // font-size: rem(16px);
    padding: 0.5rem;

    line-height: 1.5rem;
    @include border(--bd-soft, $loc: top);

    &._fresh {
      @include bgcolor(warning, 5, 1);
    }

    :global(.cv-user) {
      @include fgcolor(primary, 5);
    }
  }

  .notif-foot {
    margin-top: 0.25rem;
    @include ftsize(sm);
    @include fgcolor(tert);
  }

  .pagi {
    margin-top: 0.75rem;
  }
</style>
