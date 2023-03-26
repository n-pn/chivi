<script lang="ts">
  import CvreplTree from './CvreplTree.svelte'
  import CvreplForm from './CvreplForm.svelte'

  export let cvpost: CV.Cvpost
  export let tplist: CV.Cvrepl[]

  export let on_cvrepl_form = (new_repl?: CV.Cvrepl) => {
    if (new_repl) tplist.unshift(new_repl)
    tplist = tplist
  }

  function build_tree(repls: CV.Cvrepl[]) {
    const map = new Map<number, CV.Cvrepl>()

    for (const repl of repls) {
      repl.repls ||= []
      map.set(repl.id, repl)
    }

    const output: CV.Cvrepl[] = []

    for (const repl of repls) {
      const parent = map.get(repl.repl_id)

      if (parent) parent.repls.push(repl)
      else output.push(repl)
    }

    return output
  }
</script>

<div class="new-repl">
  <CvreplForm cvpost_id={cvpost.id} on_destroy={on_cvrepl_form} />
</div>

{#if tplist.length > 0}
  <CvreplTree
    {cvpost}
    repls={build_tree(tplist)}
    level={0}
    fluid={$$props.fluid} />
{:else}
  <div class="empty">Chưa có bình luận</div>
{/if}

<style lang="scss">
  .new-repl {
    display: block;
  }

  .empty {
    @include flex-ca();
    height: 10rem;
    max-height: 30vh;
    font-style: italic;
    @include fgcolor(tert);
  }
</style>
