<script context="module" lang="ts">
  import { page } from '$app/stores'

  import CvreplTree from './CvreplTree.svelte'
  import CvreplCard from './CvreplCard.svelte'
  import CvreplForm from './CvreplForm.svelte'
</script>

<script lang="ts">
  export let cvpost: CV.Cvpost
  export let tplist: CV.Cvrepl[]

  export let on_cvrepl_form = (dirty = false) => {
    if (dirty) window.location.reload()
  }

  function build_tree(repls: CV.Cvrepl[]) {
    const map = new Map<number, CV.Cvrepl>()

    for (const repl of repls) {
      repl.repls ||= []
      map.set(repl.id, repl)
    }

    const output: CV.Cvrepl[] = []

    for (const repl of repls) {
      const parent = map.get(repl.rp_id)

      if (parent) parent.repls.push(repl)
      else output.push(repl)
    }

    return output
  }
</script>

{#if tplist.length > 0}
  <CvreplTree
    {cvpost}
    repls={build_tree(tplist)}
    level={0}
    fluid={$$props.fluid} />
{:else}
  <div class="empty">Chưa có bình luận</div>
{/if}

<dtlist-foot>
  <CvreplForm cvpost_id={cvpost.id} on_destroy={on_cvrepl_form} />
</dtlist-foot>

<style lang="scss">
  dtlist-foot {
    display: block;

    margin-top: 0.75rem;
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
