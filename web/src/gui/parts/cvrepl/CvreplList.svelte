<script context="module" lang="ts">
  import { page } from '$app/stores'

  import CvreplCard from './CvreplCard.svelte'
  import CvreplForm from './CvreplForm.svelte'
</script>

<script lang="ts">
  export let cvpost: CV.Cvpost
  export let tplist: CV.Cvrepl[]

  export let on_cvrepl_form = (dirty = false) => {
    if (dirty) window.location.reload()
  }

  let active_card = $page.url.hash.substring(1)
</script>

<cvrepl-list>
  {#each tplist as cvrepl}
    <CvreplCard {cvrepl} bind:active_card fluid={$$props.fluid} />
  {:else}
    <div class="empty">Chưa có bình luận</div>
  {/each}

  <dtlist-foot>
    <CvreplForm cvpost_id={cvpost.id} on_destroy={on_cvrepl_form} />
  </dtlist-foot>
</cvrepl-list>

<style lang="scss">
  cvrepl-list {
    // margin-left: 0.75rem;
    display: block;
    padding-bottom: 0.75rem;
  }

  dtlist-foot {
    display: block;

    @include border($loc: top);
  }

  .empty {
    @include flex-ca();
    height: 10rem;
    max-height: 30vh;
    font-style: italic;
    @include fgcolor(tert);
  }
</style>
